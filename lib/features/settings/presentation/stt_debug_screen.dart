import 'package:flutter/material.dart';
import '../../../core/services/stt_diagnostic.dart';

class SttDebugScreen extends StatefulWidget {
  const SttDebugScreen({super.key});

  @override
  State<SttDebugScreen> createState() => _SttDebugScreenState();
}

class _SttDebugScreenState extends State<SttDebugScreen> {
  String _report = 'Tap "Run Diagnostic" to test STT...';
  bool _loading = false;

  void _runDiagnostic() async {
    setState(() {
      _loading = true;
      _report = 'Running diagnostic...';
    });

    try {
      final report = await SttDiagnostic.runFullDiagnostic();
      setState(() {
        _report = report;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _report = 'Error running diagnostic:\n$e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('STT Diagnostic'),
        backgroundColor: Colors.blueGrey,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              onPressed: _loading ? null : _runDiagnostic,
              icon: const Icon(Icons.bug_report),
              label: _loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Run Diagnostic'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: SelectableText(
                _report,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'What to do with the results:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '1. Check if "Initialization" is SUCCESS\n'
                      '2. Check if "Sound detected" is YES\n'
                      '3. See recommendations at the bottom\n\n'
                      'If issues found, check STT_DEBUGGING_GUIDE.md for fixes.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
