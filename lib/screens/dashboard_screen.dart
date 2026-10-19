import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _authService = AuthService();
  final _firestoreService = FirestoreService();

  // Quick logout
  Future<void> _logout() async {
    await _authService.logout();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  // Quick test add patient
  Future<void> _addTestPatient() async {
    await _firestoreService.createPatient(
      name: 'Test Patient',
      dateOfBirth: '1990-01-01',
      gender: 'Male',
      idNumber: '123456789',
      address: '123 Main St',
      phoneNumber: '0821234567',
      medicalAidNumber: 'MED123',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medibrief Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _firestoreService.getAllPatients(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No patients found. Add one!'));
          }

          final patients = snapshot.data!.docs;

          return ListView.builder(
            itemCount: patients.length,
            itemBuilder: (context, index) {
              final patient = patients[index].data();
              return ListTile(
                leading: const Icon(Icons.person),
                title: Text(patient['name'] ?? 'Unknown Name'),
                subtitle: Text('ID: ${patient['idNumber'] ?? 'N/A'}'),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addTestPatient,
        icon: const Icon(Icons.add),
        label: const Text('Add Test Patient'),
      ),
    );
  }
}