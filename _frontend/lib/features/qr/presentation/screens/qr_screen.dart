import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../bloc/qr_bloc.dart';
import '../bloc/qr_event.dart';
import '../bloc/qr_state.dart';
import '../../../../shared/theme/app_theme.dart';

class QrScreen extends StatefulWidget {
  const QrScreen({super.key});

  @override
  State<QrScreen> createState() => _QrScreenState();
}

class _QrScreenState extends State<QrScreen> {
  Timer? _timer;
  int _timeLeft = 30;

  @override
  void initState() {
    super.initState();
    context.read<QrBloc>().add(GenerateQr());
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timeLeft = 30;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_timeLeft > 0) {
            _timeLeft--;
          } else {
            context.read<QrBloc>().add(GenerateQr());
            _timeLeft = 30;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = _timeLeft / 30.0;
    final color = progress > 0.5 ? Colors.green : (progress > 0.2 ? Colors.orange : Colors.red);

    return Scaffold(
      appBar: AppBar(title: const Text('Acceso QR')),
      body: BlocBuilder<QrBloc, QrState>(
        builder: (context, state) {
          if (state is QrLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is QrLoaded) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.8, end: 1.0),
                    duration: const Duration(milliseconds: 500),
                    builder: (context, val, child) {
                      return Transform.scale(scale: val, child: child);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 2)
                        ]
                      ),
                      child: QrImageView(
                        data: state.qrToken.token,
                        size: 220,
                        backgroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: 220,
                    child: LinearProgressIndicator(
                      value: progress,
                      color: color,
                      backgroundColor: Colors.grey[300],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Actualizando en $_timeLeft s', style: AppTextStyles.body),
                  const SizedBox(height: 32),
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Este código es personal e intransferible.', style: TextStyle(color: Colors.grey)),
                    ),
                  )
                ],
              ),
            );
          } else if (state is QrError) {
            return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
          }
          return const SizedBox();
        },
      ),
    );
  }
}
