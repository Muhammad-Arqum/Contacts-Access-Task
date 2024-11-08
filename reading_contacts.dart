import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

void main() => runApp(ContactsApp());

class ContactsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ContactsScreen(),
    );
  }
}

class ContactsScreen extends StatefulWidget {
  @override
  _ContactsScreenState createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  List<Contact> _contacts = [];
  List<Contact> _filteredContacts = [];
  bool _permissionDenied = false;

  @override
  void initState() {
    super.initState();
    _fetchContacts();
  }

  Future<void> _fetchContacts() async {
    // Request permission to access contacts
    if (await FlutterContacts.requestPermission()) {
      List<Contact> contacts =
          await FlutterContacts.getContacts(withProperties: true);
      setState(() {
        _contacts = contacts;
        _filteredContacts =
            contacts; // Initialize filtered list to display all contacts initially
      });
    } else {
      setState(() {
        _permissionDenied = true;
      });
    }
  }

  void _filterContacts(String searchText) {
    setState(() {
      _filteredContacts = _contacts
          .where((contact) => contact.displayName
              .toLowerCase()
              .contains(searchText.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_permissionDenied) {
      return Scaffold(
        appBar: AppBar(title: Text("Contacts")),
        body: Center(
          child: Text("Permission to access contacts was denied."),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Contacts'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search Contacts',
                border: OutlineInputBorder(),
              ),
              onChanged: _filterContacts,
            ),
          ),
          Expanded(
            child: _contacts.isEmpty
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _filteredContacts.length,
                    itemBuilder: (context, index) {
                      final contact = _filteredContacts[index];
                      return ListTile(
                        title: Text(contact.displayName),
                        subtitle: Text(
                          contact.phones.isNotEmpty
                              ? contact.phones.first.number
                              : 'No phone number',
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
