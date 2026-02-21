import 'package:flutter/material.dart';
import 'package:frontend/configurations/routes/app_routes.dart';
import 'package:frontend/data/services/user_service.dart';
import 'package:frontend/utils/validators/validations.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
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
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String? _selectedCountry;
  String? _selectedCity;
  bool _isLoading = false;

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

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    final passwordError = validatePassword(value);
    if (passwordError != null) {
      return passwordError;
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCountry == null || _selectedCity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select country and city')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final userService = UserService();
    final success = await userService.signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      username: _usernameController.text.trim(),
      country: _selectedCountry!,
      city: _selectedCity!,
    );

    setState(() => _isLoading = false);

    if (success) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.loginScreen);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Username or Email already in Use')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: const Text(
          'Feel chat',
          style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter your email',
                ),
                validator: validateEmail,
                maxLength: 320,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  hintText: 'Enter your username',
                ),
                validator: validateUsername,
                maxLength: 20,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter your password',
                ),
                validator: validatePassword,
                obscureText: true,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Confirm Password',
                  hintText: 'Confirm your password',
                ),
                validator: _validateConfirmPassword,
                obscureText: true,
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
                isExpanded: true,
              ),
              const SizedBox(height: 16),
              DropdownButton<String>(
                hint: const Text('Select City'),
                value: _selectedCity,
                onChanged: _selectedCountry != null
                    ? (value) {
                        setState(() {
                          _selectedCity = value;
                        });
                      }
                    : null,
                items: _cityItems,
                isExpanded: true,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleSignUp,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
