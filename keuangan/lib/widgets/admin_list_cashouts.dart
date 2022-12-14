import 'package:flutter/material.dart';
import 'package:e_waste_bank_mobile/drawer.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
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
    CookieRequest requester = context.watch<CookieRequest>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Cashouts'),
      ),
      drawer: const MyDrawer(),
      body: FutureBuilder(
          future: fetchedCashouts,
          builder: (context, AsyncSnapshot<dynamic> snapshot) {
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
                                  checkboxValue = snapshot.data![index]
                                      .fields.approved;
                                  showDialog(
                                    context: context,
                                    builder: (_) {
                                      return AlertDialog(
                                        title: const Text('Cashout Approval'),
                                        content: SingleChildScrollView(
                                          child: FormField<bool>(
                                            key: _formKey,
                                            builder: (state) {
                                              return Column(
                                                children: <Widget>[
                                                  Row(
                                                    children: <Widget>[
                                                      Checkbox(
                                                          value: checkboxValue,
                                                          onChanged: (value) {
                                                            setState(() {
                                                              checkboxValue = value;
                                                              state.didChange(value);
                                                            });
                                                          }),
                                                      const Text('Setujui request?'),
                                                    ],
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
                                                        onPressed: () async{
                                                            // ignore: unused_local_variable
                                                            final response =
                                                            await requester
                                                                .post(
                                                                "https://e-waste-bank.up.railway.app/keuangan/edit-cashout-api/${snapshot
                                                                    .data![index]
                                                                    .pk}/",
                                                                {
                                                                  'approved': checkboxValue
                                                                      .toString()
                                                                });
                                                            if (response[
                                                            'status']) {
                                                              // ignore: use_build_context_synchronously
                                                              ScaffoldMessenger
                                                                  .of(context)
                                                                  .showSnackBar(
                                                                  SnackBar(
                                                                    backgroundColor:
                                                                    Colors.blue,
                                                                    // ignore: prefer_const_constructors
                                                                    content: Text(
                                                                      "Request user berhasil diupdate",
                                                                      style: const TextStyle(
                                                                          color: Colors
                                                                              .white),
                                                                    ),
                                                                    action:
                                                                    SnackBarAction(
                                                                      label: 'Close',
                                                                      textColor:
                                                                      Colors
                                                                          .white,
                                                                      onPressed: () {
                                                                        ScaffoldMessenger.of(
                                                                            context)
                                                                            .hideCurrentSnackBar();
                                                                      },
                                                                    ),
                                                                  ));
                                                            }
                                                            // ignore: use_build_context_synchronously
                                                            Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder: (context) => const AdminListCashoutsPage(),
                                                                )).then((value) {
                                                            setState(() {});
                                                          });
                                                        },
                                                        child: const Text('Send'),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              );
                                            },
                                          ),
                                        ),
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
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AdminListKeuanganPage(),
              ));
        },
      ),
    );
  }
}
