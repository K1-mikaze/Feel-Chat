import 'package:flutter/material.dart';
import 'package:frontend/configurations/routes/app_routes.dart';
import 'package:frontend/data/services/admin_service.dart';
import 'package:frontend/data/services/secure_storage_service.dart';
import 'package:frontend/utils/validators/validations.dart';
import 'package:frontend/views/widgets/feelchat_appbar.dart';

class UpdateUserAdminScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const UpdateUserAdminScreen({super.key, required this.user});

  @override
  State<UpdateUserAdminScreen> createState() => _UpdateUserAdminScreenState();
}

class _UpdateUserAdminScreenState extends State<UpdateUserAdminScreen> {
  static final Map<String, List<String>> _countryCities = {
    'Afghanistan': ['Kabul', 'Herat', 'Mazar-i-Sharif'],
    'Albania': ['Tirana', 'Durres', 'Vlore'],
    'Algeria': ['Algiers', 'Oran', 'Constantine'],
    'Argentina': ['Buenos Aires', 'Cordoba', 'Rosario'],
    'Australia': ['Sydney', 'Melbourne', 'Brisbane'],
    'Austria': ['Vienna', 'Graz', 'Salzburg'],
    'Bangladesh': ['Dhaka', 'Chittagong', 'Khulna'],
    'Belgium': ['Brussels', 'Antwerp', 'Ghent'],
    'Brazil': ['Sao Paulo', 'Rio de Janeiro', 'Brasilia'],
    'Canada': ['Toronto', 'Vancouver', 'Montreal'],
    'Chile': ['Santiago', 'Valparaiso', 'Concepcion'],
    'China': ['Beijing', 'Shanghai', 'Guangzhou'],
    'Colombia': ['Bogota', 'Medellin', 'Cali'],
    'Czech Republic': ['Prague', 'Brno', 'Ostrava'],
    'Denmark': ['Copenhagen', 'Aarhus', 'Odense'],
    'Egypt': ['Cairo', 'Alexandria', 'Giza'],
    'Finland': ['Helsinki', 'Espoo', 'Tampere'],
    'France': ['Paris', 'Marseille', 'Lyon'],
    'Germany': ['Berlin', 'Munich', 'Hamburg'],
    'Greece': ['Athens', 'Thessaloniki', 'Patras'],
    'Hungary': ['Budapest', 'Debrecen', 'Szeged'],
    'India': ['Mumbai', 'Delhi', 'Bangalore'],
    'Indonesia': ['Jakarta', 'Surabaya', 'Bandung'],
    'Iran': ['Tehran', 'Isfahan', 'Tabriz'],
    'Iraq': ['Baghdad', 'Basra', 'Mosul'],
    'Ireland': ['Dublin', 'Cork', 'Galway'],
    'Israel': ['Tel Aviv', 'Jerusalem', 'Haifa'],
    'Italy': ['Rome', 'Milan', 'Naples'],
    'Japan': ['Tokyo', 'Osaka', 'Kyoto'],
    'Kenya': ['Nairobi', 'Mombasa', 'Kisumu'],
    'Mexico': ['Mexico City', 'Guadalajara', 'Monterrey'],
    'Netherlands': ['Amsterdam', 'Rotterdam', 'The Hague'],
    'New Zealand': ['Auckland', 'Wellington', 'Christchurch'],
    'Nigeria': ['Lagos', 'Abuja', 'Ibadan'],
    'Norway': ['Oslo', 'Bergen', 'Trondheim'],
    'Pakistan': ['Karachi', 'Lahore', 'Islamabad'],
    'Peru': ['Lima', 'Arequipa', 'Trujillo'],
    'Philippines': ['Manila', 'Quezon City', 'Davao'],
    'Poland': ['Warsaw', 'Krakow', 'Lodz'],
    'Portugal': ['Lisbon', 'Porto', 'Faro'],
    'Romania': ['Bucharest', 'Cluj-Napoca', 'Timisoara'],
    'Russia': ['Moscow', 'Saint Petersburg', 'Novosibirsk'],
    'Saudi Arabia': ['Riyadh', 'Jeddah', 'Dammam'],
    'South Africa': ['Johannesburg', 'Cape Town', 'Durban'],
    'South Korea': ['Seoul', 'Busan', 'Incheon'],
    'Spain': ['Madrid', 'Barcelona', 'Valencia'],
    'Sweden': ['Stockholm', 'Gothenburg', 'Malmo'],
    'Switzerland': ['Zurich', 'Geneva', 'Basel'],
    'Thailand': ['Bangkok', 'Chiang Mai', 'Phuket'],
    'Turkey': ['Istanbul', 'Ankara', 'Izmir'],
    'Ukraine': ['Kyiv', 'Kharkiv', 'Odesa'],
    'United Arab Emirates': ['Dubai', 'Abu Dhabi', 'Sharjah'],
    'United Kingdom': ['London', 'Manchester', 'Birmingham'],
    'United States': ['New York', 'Los Angeles', 'Chicago'],
    'Vietnam': ['Hanoi', 'Ho Chi Minh City', 'Da Nang'],
  };

  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final AdminService _adminService = AdminService();

  String? _selectedCountry;
  String? _selectedCity;
  bool _deleted = false;
  bool _verified = false;
  bool _isApplying = false;

  String? _originalUsername;
  String? _originalCountry;
  String? _originalCity;
  bool _originalDeleted = false;
  bool _originalVerified = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final user = widget.user;
    _originalUsername = user['username'] ?? '';
    _usernameController.text = _originalUsername!;
    _selectedCountry = _originalCountry = user['country'];
    _selectedCity = _originalCity = user['city'];
    _deleted = _originalDeleted =
        user['deleted'] == true || user['deleted'] == 'true';
    _verified = _originalVerified =
        user['verified'] == true || user['verified'] == 'true';
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  static List<DropdownMenuItem<String>> get _countryItems =>
      (_countryCities.keys.toList()..sort())
          .map(
            (country) => DropdownMenuItem(value: country, child: Text(country)),
          )
          .toList();

  List<DropdownMenuItem<String>> get _cityItems {
    if (_selectedCountry == null) return [];
    return (_countryCities[_selectedCountry] ?? [])
        .map((city) => DropdownMenuItem(value: city, child: Text(city)))
        .toList();
  }

  bool get _hasChanges =>
      _usernameController.text != _originalUsername ||
      _selectedCountry != _originalCountry ||
      _selectedCity != _originalCity ||
      _deleted != _originalDeleted ||
      _verified != _originalVerified ||
      _passwordController.text.isNotEmpty;

  String? validatePasswordOptional(String? value) {
    if (value == null || value.isEmpty) return null;
    return validatePassword(value);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _applyChanges() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      _showMessage('Passwords do not match');
      return;
    }

    if (!_hasChanges) {
      _showMessage('No changes to apply');
      return;
    }

    setState(() => _isApplying = true);

    final secureStorage = SecureStorageService();
    final sessionId = await secureStorage.read('session-id');
    final userId = await secureStorage.read('id');

    if (sessionId == null || userId == null) {
      setState(() => _isApplying = false);
      _showMessage('Error: Missing session');
      return;
    }

    final userMap = {
      'id': widget.user['id'],
      'username': _usernameController.text.trim(),
      'password': _passwordController.text,
      'city': _selectedCity,
      'country': _selectedCountry,
      'verified': _verified,
      'deleted': _deleted,
    };

    final success = await _adminService.updateUser(sessionId, userId, userMap);

    setState(() => _isApplying = false);

    if (mounted) {
      if (success) {
        _showMessage('User updated successfully');
        Navigator.pop(context, true);
        Navigator.pushReplacementNamed(context, AppRoutes.adminScreen);
      } else {
        _showMessage('Failed to update user');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: feelchatAppbar(context, title: 'Update User'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
                validator: validateUsername,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  hintText: 'Leave empty to keep current password',
                ),
                validator: validatePasswordOptional,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirm Password',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value != _passwordController.text
                    ? 'Passwords do not match'
                    : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedCountry,
                decoration: const InputDecoration(
                  labelText: 'Country',
                  border: OutlineInputBorder(),
                ),
                hint: const Text('Select Country'),
                onChanged: (value) {
                  setState(() {
                    _selectedCountry = value;
                    _selectedCity = null;
                  });
                },
                items: _countryItems,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedCity,
                decoration: const InputDecoration(
                  labelText: 'City',
                  border: OutlineInputBorder(),
                ),
                hint: const Text('Select City'),
                onChanged: (value) {
                  setState(() {
                    _selectedCity = value;
                  });
                },
                items: _cityItems,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Deleted'),
                value: _deleted,
                onChanged: (value) {
                  setState(() => _deleted = value);
                },
              ),
              SwitchListTile(
                title: const Text('Verified'),
                value: _verified,
                onChanged: (value) {
                  setState(() => _verified = value);
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _hasChanges && !_isApplying ? _applyChanges : null,
                child: _isApplying
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Apply Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
