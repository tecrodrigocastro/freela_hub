import 'base_exception.dart';

/// Falha sem resposta do servidor (sem conexão, timeout). A UI oferece retry.
class NetworkException extends BaseException {
  const NetworkException(
      {super.message =
          'Sem conexão com o servidor. Verifique sua internet e tente novamente.'});
}
