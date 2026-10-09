import 'package:base_clean_arch_bloc/src/app/features/vagas/domain/entities/categoria_entity.dart';
import 'package:base_clean_arch_bloc/src/app/features/vagas/domain/entities/modalidade.dart';
import 'package:base_clean_arch_bloc/src/app/features/vagas/domain/entities/vaga_detail_entity.dart';
import 'package:base_clean_arch_bloc/src/app/features/vagas/domain/entities/vaga_entity.dart';
import 'package:base_clean_arch_bloc/src/app/features/vagas/domain/entities/vagas_page_entity.dart';

const categoriaMobile = CategoriaEntity(id: 2, nome: 'Desenvolvimento Mobile');

VagaEntity vaga(
  int id, {
  String titulo = 'App Flutter para clínica',
  Modalidade modalidade = Modalidade.remoto,
  TipoPagamento tipo = TipoPagamento.fixo,
  double? min = 3000,
  double? max = 5000,
  int? prazo = 45,
  bool jaCandidatou = false,
}) =>
    VagaEntity(
      id: id,
      titulo: titulo,
      empresa: 'Clínica Vida',
      categoria: categoriaMobile,
      modalidade: modalidade,
      tipoPagamento: tipo,
      valorMin: min,
      valorMax: max,
      prazoDias: prazo,
      jaCandidatou: jaCandidatou,
    );

VagasPageEntity page(List<VagaEntity> vagas, {int current = 1, int last = 1}) => VagasPageEntity(vagas: vagas, currentPage: current, lastPage: last);

/// Corpo de `GET /vagas` (docs/API.md).
Map<String, dynamic> vagasJson({int current = 1, int last = 2}) => {
      'data': [
        {
          'id': 12,
          'titulo': 'App Flutter para clínica',
          'empresa': 'Clínica Vida',
          'categoria': {'id': 2, 'nome': 'Desenvolvimento Mobile'},
          'modalidade': 'remoto',
          'tipo_pagamento': 'fixo',
          'valor_min': 3000,
          'valor_max': 5000.5,
          'prazo_dias': 45,
          'publicada_em': '2026-10-01T14:00:00Z',
          'ja_candidatou': true,
        },
        {
          'id': 13,
          'titulo': 'Suporte N1',
          'empresa': 'Estúdio Pixel',
          'categoria': {'id': 8, 'nome': 'QA e Suporte'},
          'modalidade': 'presencial',
          'tipo_pagamento': 'hora',
          'valor_min': null,
          'valor_max': null,
          'prazo_dias': null,
          'ja_candidatou': false,
        },
      ],
      'links': {'next': null, 'prev': null},
      'meta': {'current_page': current, 'last_page': last, 'total': 12},
    };

VagaDetailEntity vagaDetail({
  int id = 12,
  String descricao = 'Precisamos de um app para agendamento.\n\nExperiência com BLoC é um diferencial.',
  int total = 7,
  Modalidade modalidade = Modalidade.remoto,
  TipoPagamento tipo = TipoPagamento.fixo,
  double? min = 3000,
  double? max = 5000,
  int? prazo = 45,
  bool jaCandidatou = false,
}) =>
    VagaDetailEntity(
      id: id,
      titulo: 'App Flutter para clínica',
      empresa: 'Clínica Vida',
      categoria: categoriaMobile,
      modalidade: modalidade,
      tipoPagamento: tipo,
      valorMin: min,
      valorMax: max,
      prazoDias: prazo,
      jaCandidatou: jaCandidatou,
      descricao: descricao,
      totalCandidaturas: total,
    );

/// Corpo de `GET /vagas/{id}`.
Map<String, dynamic> vagaDetailJson() => {
      'data': {
        'id': 12,
        'titulo': 'App Flutter para clínica',
        'empresa': 'Clínica Vida',
        'categoria': {'id': 2, 'nome': 'Desenvolvimento Mobile'},
        'modalidade': 'remoto',
        'tipo_pagamento': 'fixo',
        'valor_min': 3000,
        'valor_max': 5000,
        'prazo_dias': 45,
        'publicada_em': '2026-10-01T14:00:00Z',
        'ja_candidatou': false,
        'descricao': 'Texto completo.',
        'total_candidaturas': 7,
      },
    };
