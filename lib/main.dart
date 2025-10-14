import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'instancia_bd.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _controllerDNI = TextEditingController();
  final TextEditingController _controllerNombre = TextEditingController();
  
  late Future<List> listaUsuarios;

  @override
  void initState() {
    super.initState();
    listaUsuarios = obtenerUsuario();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Firebase"),
      ),
      body: FutureBuilder<List>(
        future: listaUsuarios,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return const Center(
              child: Text("Error al cargar usuarios"),
            );
          } else if (snapshot.hasData) {
            return ListView.separated(
              itemCount: snapshot.data!.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final usuario = snapshot.data![index];
                final dni = usuario['dni'];
                final nombre = usuario['nombre'];
                final uid = usuario['uid'];
                return ListTile(
                  title: Text(nombre),
                  subtitle: Text("DNI: $dni"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min, // Importante para que no ocupe mucho espacio
                    children: [
                      // ÍCONO DE EDICIÓN (LÁPIZ)
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          _showEditDialog(uid, dni, nombre);
                        },
                      ),
                      // ÍCONO DE ELIMINACIÓN
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _eliminarUsuario(uid);
                        },
                      ),
                    ],
                  ),
                  // También puedes mantener el onTap si quieres
                  onTap: () {
                    _showEditDialog(uid, dni, nombre);
                  },
                );
              },
            );
          } else {
            return const Center(
              child: Text("No se encontraron usuarios."),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _dialogAgregarUsuario();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _mostrarLista() {
    setState(() {
      listaUsuarios = obtenerUsuario();
    });
  }

  void _dialogAgregarUsuario() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Agregar Usuario"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _controllerDNI,
                decoration: const InputDecoration(hintText: "DNI"),
              ),
              TextField(
                controller: _controllerNombre,
                decoration: const InputDecoration(hintText: "Nombre"),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                await agregarUsuario(
                  _controllerDNI.text.toString(),
                  _controllerNombre.text.toString(),
                ).then((_) {
                  Navigator.of(context).pop();
                  _mostrarLista();
                  _controllerDNI.clear();
                  _controllerNombre.clear();
                });
              },
              child: const Text("Guardar"),
            )
          ],
        );
      },
    );
  }

  void _eliminarUsuario(String uid) async {
    await eliminarUsuario(uid).then((_) {
      _mostrarLista();
    });
  }

  void _actualizarUsuario(String uid, String dni, String nombre) async {
    await actualizarUsuario(uid, dni, nombre).then((_) {
      _mostrarLista();
    });
  }

  void _showEditDialog(String uid, String dni, String currentNombre) {
    TextEditingController _nombreController = TextEditingController(text: currentNombre);
    TextEditingController _dniController = TextEditingController(text: dni);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Editar Usuario"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _dniController,
                decoration: const InputDecoration(
                  labelText: "DNI",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: "Nombre",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () {
                String nuevoNombre = _nombreController.text;
                String nuevoDni = _dniController.text;
                if (nuevoNombre.isNotEmpty && nuevoDni.isNotEmpty) {
                  _actualizarUsuario(uid, nuevoDni, nuevoNombre);
                }
                Navigator.of(context).pop();
              },
              child: const Text("Guardar Cambios"),
            ),
          ],
        );
      },
    );
  }
}