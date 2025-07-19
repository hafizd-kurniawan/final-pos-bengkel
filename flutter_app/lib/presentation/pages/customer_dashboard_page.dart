import 'package:flutter/material.dart';
import '../../data/models/vehicle.dart';
import '../../data/models/test_drive.dart';
import '../../data/datasources/api_service_locator.dart';
import '../widgets/vehicle_grid_widget.dart';
import '../widgets/test_drive_card.dart';

class CustomerDashboardPage extends StatefulWidget {
  const CustomerDashboardPage({super.key});

  @override
  State<CustomerDashboardPage> createState() => _CustomerDashboardPageState();
}

class _CustomerDashboardPageState extends State<CustomerDashboardPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Vehicle> _featuredVehicles = [];
  List<Vehicle> _recentlyViewed = [];
  List<TestDrive> _myTestDrives = [];
  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final vehiclesFuture = apiServices.vehicleService
          .getVehicles(status: 'available', limit: 20);
      final testDrivesFuture = apiServices.testDriveService
          .getMyTestDrives(limit: 10);

      final results = await Future.wait([
        vehiclesFuture,
        testDrivesFuture,
      ]);

      final allVehicles = results[0] as List<Vehicle>;
      _featuredVehicles = allVehicles.take(8).toList();
      _recentlyViewed = allVehicles.skip(8).take(6).toList();
      _myTestDrives = results[1] as List<TestDrive>;

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore Vehicles'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.home), text: 'Browse'),
            Tab(icon: Icon(Icons.drive_eta), text: 'Test Drives'),
            Tab(icon: Icon(Icons.favorite), text: 'Favorites'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              _showSearchDialog(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterDialog(context);
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorWidget()
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildBrowseTab(),
                    _buildTestDrivesTab(),
                    _buildFavoritesTab(),
                  ],
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showQuickActionsMenu(context);
        },
        label: const Text('Quick Book'),
        icon: const Icon(Icons.schedule),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load vehicles',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            _error!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadData,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildBrowseTab() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            _buildWelcomeSection(),
            const SizedBox(height: 24),

            // Search Bar
            _buildSearchBar(),
            const SizedBox(height: 24),

            // Featured Vehicles
            _buildFeaturedSection(),
            const SizedBox(height: 24),

            // Categories
            _buildCategoriesSection(),
            const SizedBox(height: 24),

            // Recently Viewed
            if (_recentlyViewed.isNotEmpty) ...[
              _buildRecentlyViewedSection(),
              const SizedBox(height: 24),
            ],

            // Popular Models
            _buildPopularModelsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Find Your Dream Car',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Browse our collection of premium vehicles and book test drives instantly',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              _navigateToVehicleSearch();
            },
            icon: const Icon(Icons.search),
            label: const Text('Browse All Vehicles'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'Search by make, model, or year...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: IconButton(
            icon: const Icon(Icons.tune),
            onPressed: () => _showFilterDialog(context),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Featured Vehicles',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            TextButton(
              onPressed: () {
                _navigateToVehicleSearch();
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        VehicleGridWidget(
          vehicles: _featuredVehicles,
          onVehicleTap: _onVehicleTap,
          crossAxisCount: 2,
          childAspectRatio: 0.8,
        ),
      ],
    );
  }

  Widget _buildCategoriesSection() {
    final categories = [
      {'name': 'Sedans', 'icon': Icons.directions_car, 'color': Colors.blue},
      {'name': 'SUVs', 'icon': Icons.directions_car, 'color': Colors.green},
      {'name': 'Trucks', 'icon': Icons.local_shipping, 'color': Colors.orange},
      {'name': 'Luxury', 'icon': Icons.star, 'color': Colors.purple},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Browse by Category',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 2.5,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: categories.map((category) {
            return Card(
              child: InkWell(
                onTap: () {
                  _navigateToCategory(category['name'] as String);
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        category['icon'] as IconData,
                        color: category['color'] as Color,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        category['name'] as String,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRecentlyViewedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recently Viewed',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _recentlyViewed.length,
            itemBuilder: (context, index) {
              final vehicle = _recentlyViewed[index];
              return Container(
                width: 160,
                margin: const EdgeInsets.only(right: 12),
                child: _buildVehicleCard(vehicle),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPopularModelsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Popular This Month',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        VehicleGridWidget(
          vehicles: _featuredVehicles.take(4).toList(),
          onVehicleTap: _onVehicleTap,
          crossAxisCount: 1,
          childAspectRatio: 3,
        ),
      ],
    );
  }

  Widget _buildVehicleCard(Vehicle vehicle) {
    return Card(
      child: InkWell(
        onTap: () => _onVehicleTap(vehicle),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.2),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: vehicle.primaryImage != null
                    ? ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                        child: Image.network(
                          vehicle.primaryImage!.url,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.directions_car, size: 48);
                          },
                        ),
                      )
                    : const Icon(Icons.directions_car, size: 48),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vehicle.displayName,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    vehicle.priceFormatted,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestDrivesTab() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: _myTestDrives.isEmpty
          ? _buildEmptyTestDrives()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _myTestDrives.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildTestDrivesHeader();
                }

                final testDrive = _myTestDrives[index - 1];
                return TestDriveCard(
                  testDrive: testDrive,
                  onTap: () => _onTestDriveTap(testDrive),
                  onCancel: () => _cancelTestDrive(testDrive),
                );
              },
            ),
    );
  }

  Widget _buildEmptyTestDrives() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.drive_eta,
            size: 64,
            color: Colors.grey.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No Test Drives Scheduled',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Book a test drive to experience our vehicles firsthand',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              _tabController.animateTo(0); // Go to browse tab
            },
            icon: const Icon(Icons.schedule),
            label: const Text('Schedule Test Drive'),
          ),
        ],
      ),
    );
  }

  Widget _buildTestDrivesHeader() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'My Test Drives (${_myTestDrives.length})',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              _showScheduleTestDriveDialog(context);
            },
            icon: const Icon(Icons.add),
            label: const Text('Schedule'),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesTab() {
    return const Center(
      child: Text('Favorites feature coming soon'),
    );
  }

  // Event handlers and helper methods
  void _onVehicleTap(Vehicle vehicle) {
    // Navigate to vehicle details
    Navigator.pushNamed(context, '/vehicle-details', arguments: vehicle);
  }

  void _onTestDriveTap(TestDrive testDrive) {
    // Navigate to test drive details
  }

  void _navigateToVehicleSearch() {
    // Navigate to full vehicle search/browse
  }

  void _navigateToCategory(String category) {
    // Navigate to category-specific vehicles
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Vehicles'),
        content: const Text('Advanced search dialog would be implemented here'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Vehicles'),
        content: const Text('Filter dialog would be implemented here'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showQuickActionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.schedule, color: Colors.blue),
              title: const Text('Schedule Test Drive'),
              onTap: () {
                Navigator.pop(context);
                _showScheduleTestDriveDialog(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.search, color: Colors.green),
              title: const Text('Search Vehicles'),
              onTap: () {
                Navigator.pop(context);
                _showSearchDialog(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.favorite, color: Colors.red),
              title: const Text('View Favorites'),
              onTap: () {
                Navigator.pop(context);
                _tabController.animateTo(2);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showScheduleTestDriveDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Schedule Test Drive'),
        content: const Text('Test drive scheduling dialog would be implemented here'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Schedule'),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelTestDrive(TestDrive testDrive) async {
    try {
      await apiServices.testDriveService.cancelTestDrive(testDrive.id);
      _loadData(); // Refresh data
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Test drive canceled successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to cancel test drive: $e')),
        );
      }
    }
  }
}