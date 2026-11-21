import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://wujzkjqorhvwsivfjxlq.supabase.co',
    anonKey: 'sb_publishable_0Pb3CecDAPpti5NHPT9JnA_5BApQ-5E',
  );
  runApp(const ProviderScope(child: JustMoveItApp()));
}
