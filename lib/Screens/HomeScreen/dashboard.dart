import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shrink_sidemenu/shrink_sidemenu.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import '../../Widgets/custome_bottom_bar.dart';
import '../../Widgets/snack_bar.dart';
import '../OnBoardingScreen/login_screen.dart';
import 'slider_menu.dart';
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
  int _currentIndex = 0;
  String _selectedFilter = "Month"; // Default filter
  DateTime _focusedDate = DateTime.now();
  final GlobalKey<SideMenuState> _sideMenuKey = GlobalKey<SideMenuState>();
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
    return SideMenu(
      key: _sideMenuKey,
      menu: SliderMenu(
        userName: _userName,
        userEmail: _userEmail,
        selectedTitle: _currentIndex == 0
            ? "Home"
            : _currentIndex == 1
            ? "My Wallet"
            : _currentIndex == 2
            ? "Savings"
            : "Profile",
        onItemClick: (title) async {
          _sideMenuKey.currentState!.closeSideMenu();
          if (title == "Home") {
            _onItemTapped(0);
          } else if (title == "My Wallet") {
            _onItemTapped(1);
          } else if (title == "Logout") {
            try {
              await FirebaseAuth.instance.signOut();
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            } catch (e) {
              if (mounted)
                KSnackBar.showError(context, message: "Logout failed: $e");
            }
          }
        },
      ),
      type: SideMenuType.shrinkNSlide, // Most modern style
      background: const Color(0xFF1E3C72),
      radius: BorderRadius.circular(30.r),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: Column(
          children: [
            // Safe Header Area (Prevents overlap with charger/status bar)
            _buildModernHeader(),

            Expanded(
              child: ClipRRect(
                borderRadius: _currentIndex == 0
                    ? BorderRadius.zero
                    : BorderRadius.vertical(top: Radius.circular(30.r)),
                child: PageView(
                  controller: _pageController,
                  physics:
                      const NeverScrollableScrollPhysics(), // Only navigate via bottom bar
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
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutQuart,
    );
  }

  Widget _buildModernHeader() {
    return Container(
      // Padding handles the status bar (time/charger) safely
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10.h,
        left: 20.w,
        right: 20.w,
        bottom: 15.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFF1E3C72).withAlpha(30),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(
              Icons.align_horizontal_left_rounded,
              color: const Color(0xFF1E3C72),
              size: 28.sp,
            ),
            onPressed: () {
              final state = _sideMenuKey.currentState!;
              if (state.isOpened) {
                state.closeSideMenu();
              } else {
                state.openSideMenu();
              }
            },
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Hello, $_userName!",
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.black54,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  "Welcome Back",
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF1E3C72),
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () =>
                _onItemTapped(3), // Navigate to Profile Screen (Index 3 now)
            child: Container(
              padding: EdgeInsets.all(2.r),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF1E3C72).withAlpha(30),
                  width: 1,
                ),
              ),
              child: CircleAvatar(
                radius: 18.r,
                backgroundColor: const Color(0xFF1E3C72).withAlpha(15),
                child: Icon(
                  Icons.person_outline_rounded,
                  color: const Color(0xFF1E3C72),
                  size: 20.sp,
                ),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1E3C72).withAlpha(15),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                Icons.notifications_none_rounded,
                size: 24.sp,
                color: const Color(0xFF1E3C72),
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
          // Modern Balance Card (Reduced Height)
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E3C72), Color(0xFF2A5298)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(25.r),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1E3C72).withAlpha(76),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Total $_selectedFilter Expenses",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13.sp,
                          ),
                        ),
                        Text(
                          "₹ ${totalFilterExpense.toStringAsFixed(0)}",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28.sp,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    // Modern Calendar Filter Menu
                    GestureDetector(
                      onTap: () async {
                        DateTime? dateTime = await showOmniDateTimePicker(
                          context: context,
                          initialDate: _focusedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                          is24HourMode: false,
                          isShowSeconds: false,
                          minutesInterval: 1,
                          secondsInterval: 1,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(16),
                          ),
                          constraints: const BoxConstraints(
                            maxWidth: 350,
                            maxHeight: 650,
                          ),
                          transitionBuilder: (context, anim1, anim2, child) {
                            return FadeTransition(opacity: anim1, child: child);
                          },
                          transitionDuration: const Duration(milliseconds: 200),
                          barrierDismissible: true,
                        );
                        if (dateTime != null) {
                          setState(() {
                            _focusedDate = dateTime;
                            // Optionally switch filter based on how precise they picked
                            // For simplicity, we keep the filter but update the focus
                          });
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.all(10.r),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(40),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Icon(
                          Icons.calendar_month_rounded,
                          color: Colors.white,
                          size: 20.sp,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15.h),

                // Expense Summary Line (Modern Pills)
                Row(
                  children: [
                    _buildSmallPill("Day"),
                    SizedBox(width: 8.w),
                    _buildSmallPill("Month"),
                    SizedBox(width: 8.w),
                    _buildSmallPill("Year"),
                    const Spacer(),
                    Text(
                      _selectedFilter == "Day"
                          ? DateFormat('MMM dd, yyyy').format(_focusedDate)
                          : _selectedFilter == "Month"
                          ? DateFormat('MMMM yyyy').format(_focusedDate)
                          : DateFormat('yyyy').format(_focusedDate),
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 15.h),

                // Today's Spent Section (Smaller)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 15.w,
                    vertical: 12.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(20),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: Colors.white.withAlpha(30)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.bolt_rounded,
                        color: Colors.orangeAccent,
                        size: 18.sp,
                      ),
                      SizedBox(width: 12.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Today's Spending",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 10.sp,
                            ),
                          ),
                          Text(
                            "₹ ${todayExpense.toStringAsFixed(0)}",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(40),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          "Live",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
                  color: Colors.black87,
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
                      style: TextStyle(color: Colors.black45, fontSize: 14.sp),
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

  Widget _buildSmallPill(String title) {
    bool isSelected = _selectedFilter == title;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = title),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withAlpha(30),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? const Color(0xFF1E3C72) : Colors.white,
            fontSize: 10.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
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
            style: TextStyle(color: Colors.white, fontSize: 13.sp),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
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
                    color: Colors.black87,
                  ),
                ),
                Text(
                  category,
                  style: TextStyle(fontSize: 12.sp, color: Colors.black45),
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
