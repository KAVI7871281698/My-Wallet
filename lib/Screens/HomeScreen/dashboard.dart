import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wallet/Core/app_image.dart';
import '../../Bloc/bloc.dart';
import '../../Bloc/bloc_event.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import '../../Widgets/custome_bottom_bar.dart';
import 'expense_screen.dart';
import 'profile_screen.dart';
import 'saving_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../Services/auth_service.dart';
import '../../Services/expense_service.dart';
import '../../Models/user_model.dart';
import '../../Models/expense_model.dart';
import '../../Core/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentIndex = 0;
  String _selectedFilter = "Month"; // Default filter
  DateTime _focusedDate = DateTime.now();
  late PageController _pageController = PageController(
    initialPage: _currentIndex,
  );

  final AuthService _authService = AuthService();
  final ExpenseService _expenseService = ExpenseService();
  String _userName = "User";
  String _userEmail = "user@mail.com";
  List<ExpenseModel> _cachedExpenses = [];
  Stream<List<ExpenseModel>>? _expenseStream;
  String? _lastStreamUid; // Track to prevent stream reset

  @override
  void initState() {
    super.initState();
    _loadCachedData();
    _initStreams();
  }

  void _initStreams() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && _lastStreamUid != user.uid) {
      _lastStreamUid = user.uid;
      _expenseStream = _expenseService.getExpenses(user.uid);
    }

    // Listen for auth changes to update the stream ONLY if user ID changed
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null && _lastStreamUid != user.uid) {
        setState(() {
          _lastStreamUid = user.uid;
          _expenseStream = _expenseService.getExpenses(user.uid);
        });
        _loadUserData();
      }
    });
  }

  Future<void> _loadCachedData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      // 1. Load Name
      String? cachedName = prefs.getString('user_name');
      String? cachedEmail = prefs.getString('user_email');

      String? expensesJson = prefs.getString('cached_expenses');
      List<ExpenseModel> loadedExpenses = [];
      if (expensesJson != null) {
        final List<dynamic> decoded = jsonDecode(expensesJson);
        loadedExpenses = decoded
            .map((e) => ExpenseModel.fromMap(e, e['id'] ?? ''))
            .toList();
      }

      setState(() {
        if (cachedName != null) _userName = cachedName;
        if (cachedEmail != null) _userEmail = cachedEmail;
        _cachedExpenses = loadedExpenses;
      });
    } catch (e) {
      debugPrint("Error loading cached data: $e");
    }
  }

  Future<void> _saveExpensesToCache(List<ExpenseModel> expenses) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final String encoded = jsonEncode(
        expenses
            .take(20)
            .map((e) => e.toMap(forFirestore: false)..['id'] = e.id)
            .toList(),
      );
      await prefs.setString('cached_expenses', encoded);
    } catch (e) {
      debugPrint("Error saving expenses to cache: $e");
    }
  }

  Future<void> _loadUserData() async {
    try {
      // 1. Load from cache immediately for speed
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? cachedName = prefs.getString('user_name');
      String? cachedEmail = prefs.getString('user_email');
      setState(() {
        if (cachedName != null) _userName = cachedName;
        if (cachedEmail != null) _userEmail = cachedEmail;
      });

      // 2. Fetch from Firebase in background to update
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        UserModel? data = await _authService.getUserData(user.uid);
        if (data != null) {
          setState(() {
            _userName = data.name.isNotEmpty ? data.name : "User";
            _userEmail = data.email.isNotEmpty
                ? data.email
                : user.email ?? "user@mail.com";
          });
          // Update cache
          await prefs.setString('user_name', _userName);
          await prefs.setString('user_email', _userEmail);
        }
      }
    } catch (e) {
      debugPrint("Error loading user data: $e");
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // No longer needed as we use real data
  // final Map<String, Map<String, String>> _balanceData = {...};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          _buildModernHeader(),
          Expanded(
            child: ClipRRect(
              borderRadius: _currentIndex == 0
                  ? BorderRadius.zero
                  : BorderRadius.vertical(top: Radius.circular(30.r)),
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                children: [
                  _HomeContent(
                    expenseStream: _expenseStream,
                    cachedExpenses: _cachedExpenses,
                    userName: _userName,
                    selectedFilter: _selectedFilter,
                    focusedDate: _focusedDate,
                    onFilterChanged: (filter) =>
                        setState(() => _selectedFilter = filter),
                    onDateChanged: (date) =>
                        setState(() => _focusedDate = date),
                    onRefresh: _loadUserData,
                    saveCacheFunc: _saveExpensesToCache,
                    buildHomeContent: _buildHomeContent,
                  ),
                  const ExpenseScreen(),
                  const SavingScreen(),
                  const ProfileScreen(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomBar(
        index: _currentIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  void _onItemTapped(int index) {
    _pageController.jumpToPage(index);
  }

  Widget _buildModernHeader() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 5.h,
        left: 20.w,
        right: 20.w,
        bottom: 5.h,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            height: 35.h,
            width: 40.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: const DecorationImage(
                image: AssetImage(AppImage.appIcon),
                fit: BoxFit.cover,
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).primaryColor.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Hello, $_userName',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.titleLarge?.color,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Welcome back to your wallet',
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.color?.withOpacity(0.6),
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              context.read<ThemeBloc>().add(ToggleThemeEvent());
            },
            child: Container(
              padding: EdgeInsets.all(2.r),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: CircleAvatar(
                radius: 18.r,
                backgroundColor: Theme.of(
                  context,
                ).primaryColor.withOpacity(0.15),
                child: Icon(
                  Theme.of(context).brightness == Brightness.dark
                      ? Icons.light_mode_rounded
                      : Icons.dark_mode_rounded,
                  color: Theme.of(context).primaryColor,
                  size: 20.sp,
                ),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withAlpha(15),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                Icons.notifications_none_rounded,
                size: 24.sp,
                color: Theme.of(context).primaryColor,
              ),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeContent(List<ExpenseModel> expenses) {
    // Calculate totals based on filter
    double totalFilterExpense = 0;
    double todayExpense = 0;

    final now = _focusedDate;
    for (var e in expenses) {
      // For Today's Spent Section
      if (e.date.day == DateTime.now().day &&
          e.date.month == DateTime.now().month &&
          e.date.year == DateTime.now().year) {
        todayExpense += e.amount;
      }

      // For Total Filter Card
      if (_selectedFilter == "Day") {
        if (e.date.day == now.day &&
            e.date.month == now.month &&
            e.date.year == now.year) {
          totalFilterExpense += e.amount;
        }
      } else if (_selectedFilter == "Month") {
        if (e.date.month == now.month && e.date.year == now.year) {
          totalFilterExpense += e.amount;
        }
      } else {
        // Year
        if (e.date.year == now.year) {
          totalFilterExpense += e.amount;
        }
      }
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Credit Card Style Balance
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).colorScheme.secondary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24.r),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).primaryColor.withAlpha(76),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Chip icon simulation
                    Container(
                      width: 40.w,
                      height: 28.h,
                      decoration: BoxDecoration(
                        color: Colors.amber.shade200,
                        borderRadius: BorderRadius.circular(6.r),
                        border: Border.all(
                          color: Colors.amber.shade400,
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.sim_card_outlined,
                          size: 20.sp,
                          color: Colors.amber.shade800,
                        ),
                      ),
                    ),
                    Text(
                      "Premium",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),
                Text(
                  "Total $_selectedFilter Expense",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 13.sp,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  "₹ ${totalFilterExpense.toStringAsFixed(2)}",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32.sp,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
                SizedBox(height: 20.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "CARD HOLDER",
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 10.sp,
                            letterSpacing: 1,
                          ),
                        ),
                        Text(
                          _userName.toUpperCase(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                    // MasterCard/Visa circles simulation
                    Row(
                      children: [
                        Container(
                          width: 24.w,
                          height: 24.w,
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withOpacity(0.8),
                            shape: BoxShape.circle,
                          ),
                        ),
                        Transform.translate(
                          offset: const Offset(-10, 0),
                          child: Container(
                            width: 24.w,
                            height: 24.w,
                            decoration: BoxDecoration(
                              color: Colors.orangeAccent.withOpacity(0.8),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 25.h),

          // 2. Segmented Filter & Calendar Row
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 45.h,
                  padding: EdgeInsets.all(4.r),
                  decoration: BoxDecoration(
                    color: Theme.of(context).dividerColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    children: [
                      Expanded(child: _buildSegmentBtn("Day")),
                      Expanded(child: _buildSegmentBtn("Month")),
                      Expanded(child: _buildSegmentBtn("Year")),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              GestureDetector(
                onTap: () async {
                  DateTime? dateTime = await showOmniDateTimePicker(
                    context: context,
                    initialDate: _focusedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                    is24HourMode: false,
                    isShowSeconds: false,
                  );
                  if (dateTime != null) {
                    setState(() => _focusedDate = dateTime);
                  }
                },
                child: Container(
                  height: 45.h,
                  width: 45.h,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.calendar_month_rounded,
                    color: Theme.of(context).primaryColor,
                    size: 22.sp,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 25.h),

          // 3. Quick Action Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildActionBtn(Icons.arrow_upward_rounded, "Send"),
              _buildActionBtn(Icons.arrow_downward_rounded, "Receive"),
              _buildActionBtn(Icons.account_balance_wallet_rounded, "Top Up"),
              _buildActionBtn(Icons.more_horiz_rounded, "More"),
            ],
          ),

          SizedBox(height: 35.h),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Recent Transactions",
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              Text(
                "See all",
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.blue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          SizedBox(height: 20.h),

          // Transaction List
          expenses.isEmpty
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 40.h),
                    child: Text(
                      "No transactions yet!",
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.color?.withOpacity(0.6),
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                )
              : Column(
                  children: expenses.take(20).map((e) {
                    final cat = AppConstants.getCategory(e.category);
                    return _transactionItem(
                      e.category,
                      DateFormat('MMM dd, yyyy').format(e.date),
                      "₹ -${e.amount.toStringAsFixed(0)}",
                      cat["icon"],
                      cat["color"],
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }

  Widget _buildSegmentBtn(String title) {
    bool isSelected = _selectedFilter == title;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = title),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.surface
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8.r),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Theme.of(
                    context,
                  ).textTheme.bodyMedium?.color?.withOpacity(0.5),
            fontSize: 13.sp,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildActionBtn(IconData icon, String label) {
    return Column(
      children: [
        Container(
          width: 50.w,
          height: 50.w,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Theme.of(context).primaryColor, size: 24.sp),
        ),
        SizedBox(height: 8.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: Theme.of(context).textTheme.bodyMedium?.color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  PopupMenuItem<String> _buildFilterItem(String title, IconData icon) {
    return PopupMenuItem<String>(
      value: title,
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 18.sp),
          SizedBox(width: 12.w),
          Text(
            title,
            style: TextStyle(
              color: Theme.of(context).colorScheme.surface,
              fontSize: 13.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _transactionItem(
    String title,
    String category,
    String amount,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withAlpha(20),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: color.withAlpha(25),
              borderRadius: BorderRadius.circular(15.r),
            ),
            child: Icon(icon, color: color, size: 24.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                Text(
                  category,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.color?.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w900,
              color: amount.contains('+') ? Colors.green : Colors.redAccent,
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeContent extends StatefulWidget {
  final Stream<List<ExpenseModel>>? expenseStream;
  final List<ExpenseModel> cachedExpenses;
  final String userName;
  final String selectedFilter;
  final DateTime focusedDate;
  final Function(String) onFilterChanged;
  final Function(DateTime) onDateChanged;
  final Future<void> Function() onRefresh;
  final Function(List<ExpenseModel>) saveCacheFunc;
  final Widget Function(List<ExpenseModel>) buildHomeContent;

  const _HomeContent({
    required this.expenseStream,
    required this.cachedExpenses,
    required this.userName,
    required this.selectedFilter,
    required this.focusedDate,
    required this.onFilterChanged,
    required this.onDateChanged,
    required this.onRefresh,
    required this.saveCacheFunc,
    required this.buildHomeContent,
  });

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (widget.expenseStream == null && widget.cachedExpenses.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return StreamBuilder<List<ExpenseModel>>(
      stream: widget.expenseStream,
      initialData: widget.cachedExpenses,
      builder: (context, snapshot) {
        // ALWAYS fallback to cache if stream has no data yet
        final expenses = (snapshot.hasData && snapshot.data!.isNotEmpty)
            ? snapshot.data!
            : widget.cachedExpenses;

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(20.r),
              child: Text(
                "Error: ${snapshot.error}",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.active &&
            snapshot.hasData) {
          widget.saveCacheFunc(snapshot.data!);
        }

        return RefreshIndicator(
          onRefresh: widget.onRefresh,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: widget.buildHomeContent(expenses),
          ),
        );
      },
    );
  }
}
