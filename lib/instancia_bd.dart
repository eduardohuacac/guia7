import 'package:cloud_firestore/cloud_firestore.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

Future<List> obtenerUsuario() async {
  List usuarios = [];
  try {
    CollectionReference collectionReferencePeople = db.collection("usuarios");
    QuerySnapshot queryUsuarios = await collectionReferencePeople.get();
    queryUsuarios.docs.forEach((documento) {
      Map<String, dynamic> dataConId = documento.data() as Map<String, dynamic>;
      String dni = dataConId.containsKey('dni') ? dataConId['dni'] : 'Sin DNI';
      String nombre = dataConId.containsKey('nombre') ? dataConId['nombre'] : 'Sin Nombre';
      
      usuarios.add({
        'dni': dni,
        'nombre': nombre,
        'uid': documento.id,
      });
    });
  } catch (e) {
    print("Error al obtener usuarios: $e");
  }

  return usuarios;
}

Future<void> agregarUsuario(String dni, String nombre) async {
  await db.collection("usuarios").add({"dni": dni, "nombre": nombre});
}

Future<void> actualizarUsuario(String uid, String dni, String nombre) async {
  await db.collection("usuarios").doc(uid).set({"dni": dni, "nombre": nombre});
}

Future<void> eliminarUsuario(String uid) async {
  final CollectionReference users = FirebaseFirestore.instance.collection('usuarios');
  try {
    await users.doc(uid).delete();
    print('Usuario eliminado correctamente');
  } catch (e) {
    print('Error eliminando usuario: $e');
  }
}