import 'package:flutter/material.dart';
import 'package:e_waste_bank_mobile/drawer.dart';
import 'package:keuangan/methods/get_admin_cashout.dart';
import 'package:keuangan/models/admin_cashout_model.dart';

import 'admin_list_keuangan.dart';

class AdminListCashoutsPage extends StatefulWidget {
  const AdminListCashoutsPage({Key? key}) : super(key: key);

  @override
  State<AdminListCashoutsPage> createState() => _AdminListCashoutsPageState();
}

class _AdminListCashoutsPageState extends State<AdminListCashoutsPage> {
  late Future<List<Cashout>> fetchedCashouts;
  final _formKey = GlobalKey<FormState>();
  bool? checkboxValue;

  @override
  void initState() {
    super.initState();
    fetchedCashouts = fetchAdminCashout(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Cashouts'),
      ),
      drawer: const MyDrawer(),
      body: FutureBuilder(
          future: fetchedCashouts,
          builder: (context, AsyncSnapshot snapshot) {
            if (snapshot.data == null) {
              return const Center(child: CircularProgressIndicator());
            } else {
              if (!snapshot.hasData) {
                return Column(
                  children: const [
                    Text(
                      "Tidak ada data cashout",
                      style: TextStyle(color: Color(0xff59A5D8), fontSize: 20),
                    ),
                    SizedBox(height: 8),
                  ],
                );
              } else {
                return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (_, index) => Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          padding: const EdgeInsets.all(20.0),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15.0),
                              boxShadow: [
                                BoxShadow(
                                    color: snapshot.data![index].fields.approved
                                        ? Colors.blue
                                        : Colors.red,
                                    blurRadius: 5.0)
                              ]),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              ListTile(
                                title: Text(
                                  "${snapshot.data![index].pk}. ${snapshot.data![index].fields.user}",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  "Nominal: Rp.${snapshot.data![index].fields.amount}",
                                  style: const TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                                // trailing: ,
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (_) {
                                      var emailController =
                                          TextEditingController();
                                      var messageController =
                                          TextEditingController();
                                      return AlertDialog(
                                        title: const Text('Cashout Approval'),
                                        content: SingleChildScrollView(
                                            child: Form(
                                                key: _formKey,
                                                child: Column(children: [
                                                  CheckboxListTile(
                                                    title: const Text(
                                                        'Setujui request?'),
                                                    enabled: true,
                                                    value: checkboxValue =
                                                        snapshot.data![index]
                                                            .fields.approved,
                                                    onChanged: (val) {
                                                      if (checkboxValue ==
                                                          false) {
                                                        setState(() {
                                                          checkboxValue = true;
                                                        });
                                                      } else if (checkboxValue ==
                                                          true) {
                                                        setState(() {
                                                          checkboxValue = false;
                                                        });
                                                      }
                                                    },
                                                    activeColor: Colors.blue,
                                                  ),
                                                  Row(
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.pop(context),
                                                        child: const Text('Cancel'),
                                                      ),
                                                      TextButton(
                                                        onPressed: () {
                                                          // TODO submit
                                                          Navigator.pop(context);
                                                        },
                                                        child: const Text('Send'),
                                                      ),
                                                    ],
                                                  ),

                                                ]))),
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ));
              }
            }
          }),
      floatingActionButton: FloatingActionButton.extended(
        label: const Text('Keuangan'),
        onPressed: () {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const AdminListKeuanganPage(),
              ));
        },
      ),
    );
  }
}
