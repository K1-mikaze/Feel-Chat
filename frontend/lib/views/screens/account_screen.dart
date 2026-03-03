import 'package:flutter/material.dart';
import 'package:frontend/bloc/user_data/user_data_bloc.dart';
import 'package:frontend/bloc/user_data/user_data_event.dart';
import 'package:frontend/bloc/user_data/user_data_state.dart';
import 'package:frontend/configurations/routes/app_routes.dart';
import 'package:frontend/data/services/secure_storage_service.dart';
import 'package:frontend/data/services/user_service.dart';
import 'package:frontend/utils/validators/validations.dart';
import 'package:frontend/views/widgets/feelchat_appbar.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
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

  String? _selectedCountry;
  String? _selectedCity;
  String? _selectedMood;
  String? _originalCountry;
  String? _originalCity;
  String? _originalMood;
  String? _username;
  bool _loading = true;
  bool _isApplying = false;
  final UserService _userService = UserService();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  static const Map<String, String> _moods = {
    'SAD': 'Sad',
    'HAPPY': 'Happy',
    'SLEEPY': 'Sleppy',
    'MAD': 'Mad',
  };

  @override
  void dispose() {
    _usernameController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadFromBloc();
  }

  void _loadFromBloc() {
    final state = UserDataBloc.instance.state;
    if (state is UserDataLoaded) {
      setState(() {
        _username = state.username;
        _selectedCountry = state.country;
        _selectedCity = state.city;
        _selectedMood = state.mood;
        _originalCountry = state.country;
        _originalCity = state.city;
        _originalMood = state.mood;
        _loading = false;
      });
    } else {
      UserDataBloc.instance.add(LoadUserData());
      Future.delayed(const Duration(milliseconds: 500), _loadFromBloc);
    }
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
      _selectedCountry != _originalCountry ||
      _selectedCity != _originalCity ||
      _selectedMood != _originalMood;

  Future<void> _applyChanges() async {
    if (!_hasChanges) return;

    setState(() {
      _isApplying = true;
    });

    final secureStorage = SecureStorageService();
    final sessionId = await secureStorage.read('session-id');
    final userId = await secureStorage.read('id');

    if (sessionId == null || userId == null) {
      setState(() {
        _isApplying = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Error: Missing session')));
      }
      return;
    }

    final success = await _userService.updateInformation(
      sessionId: sessionId,
      userId: userId,
      country: _selectedCountry!,
      city: _selectedCity!,
      mood: _selectedMood!,
    );

    setState(() {
      _isApplying = false;
    });

    if (success) {
      await _userService.getUser(sessionId, userId);
      await Future.delayed(const Duration(milliseconds: 300));
      _loadFromBloc();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Changes applied successfully')),
        );
        Navigator.pushReplacementNamed(context, AppRoutes.menuScreen);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to apply changes')),
        );
      }
    }
  }

  void _showChangeUsernameDialog() {
    _usernameController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Username'),
        content: TextField(
          controller: _usernameController,
          decoration: const InputDecoration(hintText: 'Enter new username'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final newUsername = _usernameController.text.trim();
              if (newUsername.isNotEmpty) {
                Navigator.pop(context);
                _changeUsername(newUsername);
              }
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _showTryOtherUsernameDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Try other username'),
        content: TextField(
          controller: _usernameController,
          decoration: const InputDecoration(hintText: 'Enter new username'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final newUsername = _usernameController.text.trim();
              if (newUsername.isNotEmpty) {
                Navigator.pop(context);
                _changeUsername(newUsername);
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  Future<void> _changeUsername(String newUsername) async {
    final secureStorage = SecureStorageService();
    final sessionId = await secureStorage.read('session-id');
    final userId = await secureStorage.read('id');

    if (sessionId == null || userId == null) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Error: Missing session')));
      }
      return;
    }

    final result = await _userService.updateUsername(
      sessionId: sessionId,
      userId: userId,
      newUsername: newUsername,
    );

    switch (result) {
      case 1:
        await _userService.getUser(sessionId, userId);
        UserDataBloc.instance.add(LoadUserData());
        _loadFromBloc();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Username updated successfully')),
          );
        }
        break;
      case 2:
        _showTryOtherUsernameDialog();
        break;
      case 3:
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Session Expired')));
          Navigator.pushReplacementNamed(context, AppRoutes.loginScreen);
        }
        break;
      default:
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to update username')),
          );
        }
    }
  }

  void _showOldPasswordDialog() {
    _oldPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Write your password'),
        content: TextField(
          controller: _oldPasswordController,
          obscureText: true,
          decoration: const InputDecoration(hintText: 'Enter your password'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final oldPassword = _oldPasswordController.text.trim();
              if (oldPassword.isNotEmpty) {
                Navigator.pop(context);
                _showNewPasswordDialog(oldPassword);
              }
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _showNewPasswordDialog(String oldPassword) {
    _newPasswordController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Write your new password'),
        content: TextField(
          controller: _newPasswordController,
          obscureText: true,
          decoration: const InputDecoration(hintText: 'Enter new password'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final newPassword = _newPasswordController.text.trim();
              final validationError = validatePassword(newPassword);
              if (validationError != null) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(validationError)));
                return;
              }
              if (newPassword.isNotEmpty) {
                Navigator.pop(context);
                _showConfirmPasswordDialog(oldPassword, newPassword);
              }
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _showConfirmPasswordDialog(String oldPassword, String newPassword) {
    _confirmPasswordController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm your new password'),
        content: TextField(
          controller: _confirmPasswordController,
          obscureText: true,
          decoration: const InputDecoration(hintText: 'Confirm new password'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final confirmPassword = _confirmPasswordController.text.trim();
              final validationError = validatePassword(confirmPassword);
              if (validationError != null) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(validationError)));
                return;
              }
              if (confirmPassword == newPassword) {
                Navigator.pop(context);
                _changePassword(oldPassword, newPassword);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Passwords do not match')),
                );
              }
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  Future<void> _changePassword(String oldPassword, String newPassword) async {
    final secureStorage = SecureStorageService();
    final sessionId = await secureStorage.read('session-id');
    final userId = await secureStorage.read('id');

    if (sessionId == null || userId == null) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Error: Missing session')));
      }
      return;
    }

    final result = await _userService.updatePassword(
      sessionId: sessionId,
      userId: userId,
      newPassword: newPassword,
      oldPassword: oldPassword,
    );

    switch (result) {
      case 1:
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Password changed successfully')),
          );
        }
        break;
      case 0:
        await secureStorage.deleteAll();
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Session Expired')));
          Navigator.pushReplacementNamed(context, AppRoutes.loginScreen);
        }
        break;
      case 2:
        _showOldPasswordDialog();
        break;
      default:
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Something went wrong')));
        }
    }
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Are you sure?'),
        content: const Text('This action can\'t be undone'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _handleDeleteAccount();
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleDeleteAccount() async {
    final secureStorage = SecureStorageService();
    final sessionId = await secureStorage.read('session-id');
    final userId = await secureStorage.read('id');

    if (sessionId == null || userId == null) return;

    final success = await _userService.delete(
      sessionId: sessionId,
      userId: userId,
    );

    if (success) {
      await secureStorage.deleteAll();
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.loginScreen);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: feelchatAppbar(
          context,
          isAdmin:
              UserDataBloc.instance.state is UserDataLoaded &&
              (UserDataBloc.instance.state as UserDataLoaded).administrator ==
                  'true',
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: feelchatAppbar(
        context,
        isAdmin:
            UserDataBloc.instance.state is UserDataLoaded &&
            (UserDataBloc.instance.state as UserDataLoaded).administrator ==
                'true',
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      child: Text(
                        _username?.isNotEmpty == true
                            ? _username![0].toUpperCase()
                            : '?',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(child: Text(_username ?? '')),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: _showChangeUsernameDialog,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButton<String>(
              hint: const Text('Select Country'),
              value: _selectedCountry,
              onChanged: (value) {
                setState(() {
                  _selectedCountry = value;
                  _selectedCity = null;
                });
              },
              items: _countryItems,
            ),
            const SizedBox(height: 16),
            DropdownButton<String>(
              hint: const Text('Select City'),
              value: _selectedCity,
              onChanged: (value) {
                setState(() {
                  _selectedCity = value;
                });
              },
              items: _cityItems,
            ),
            const SizedBox(height: 16),
            DropdownButton<String>(
              hint: const Text('Select Mood'),
              value: _selectedMood,
              onChanged: (value) {
                setState(() {
                  _selectedMood = value;
                });
              },
              items: _moods.entries
                  .map(
                    (entry) => DropdownMenuItem(
                      value: entry.key,
                      child: Text(entry.value),
                    ),
                  )
                  .toList(),
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
            const Spacer(),
            ElevatedButton(
              onPressed: _showOldPasswordDialog,
              child: const Text('Change Password'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: _showDeleteAccountDialog,
              child: const Text(
                'Delete Account',
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
