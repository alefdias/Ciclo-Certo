// Gerado automaticamente com árvore de perguntas dinâmicas (Decision Tree)
class QuestionNode {
  final String id;
  final String question;
  final Map<String, String> options;

  const QuestionNode({
    required this.id,
    required this.question,
    required this.options,
  });
}

class InteractiveQuizContent {
  static const Map<String, QuestionNode> tree = {
    'root': QuestionNode(
      id: 'root',
      question:
          'Vamos registrar seu dia no diário! O que você quer registrar primeiro?',
      options: {
        'Sintomas físicos': 'flow_pain',
        'Estado emocional': 'flow_mood',
        'Nível de energia': 'flow_energy',
        'Fluxo Menstrual': 'track_flow_type',
      },
    ),
    'flow_great': QuestionNode(
      id: 'flow_great',
      question:
          'Que maravilha! O que acha que está ajudando você a se sentir assim?',
      options: {
        'Dormi muito bem': 'great_sleep',
        'Estou na minha fase folicular/ovulação': 'great_cycle',
        'Fiz exercícios hoje': 'great_exercise',
        'Apenas acordei de bom humor': 'great_random',
      },
    ),
    'great_sleep': QuestionNode(
      id: 'great_sleep',
      question: 'O sono é fundamental! Quantas horas você dormiu?',
      options: {
        'Mais de 8 horas': 'end_great_sleep_8',
        'Entre 6 e 8 horas': 'end_great_sleep_68',
        'Menos de 6 horas, mas o sono foi profundo': 'end_great_sleep_low',
      },
    ),
    'great_cycle': QuestionNode(
      id: 'great_cycle',
      question: 'A mágica dos hormônios! Você costuma monitorar sua ovulação?',
      options: {
        'Sim, sempre anoto': 'end_great_cycle_yes',
        'Não, mas sinto no corpo': 'end_great_cycle_no',
      },
    ),
    'great_exercise': QuestionNode(
      id: 'great_exercise',
      question: 'Endorfinas no ar! Qual tipo de exercício você fez?',
      options: {
        'Cardio (corrida, dança)': 'end_great_exe_cardio',
        'Força (musculação)': 'end_great_exe_force',
        'Relaxante (yoga, alongamento)': 'end_great_exe_relax',
      },
    ),
    'great_random': QuestionNode(
      id: 'great_random',
      question:
          'Esses dias são os melhores! Quer registrar alguma conquista hoje?',
      options: {
        'Sim, vou anotar no diário': 'end_great_random_yes',
        'Não, só quero aproveitar': 'end_great_random_no',
      },
    ),
    'flow_pain': QuestionNode(
      id: 'flow_pain',
      question: 'Sinto muito por isso. Onde é o seu desconforto principal?',
      options: {
        'Cólicas no pé da barriga': 'pain_cramps',
        'Dor de cabeça / Enxaqueca': 'pain_head',
        'Dor nos seios (mastalgia)': 'pain_boobs',
        'Dor na lombar / costas': 'pain_back',
      },
    ),
    'pain_cramps': QuestionNode(
      id: 'pain_cramps',
      question: 'Entendo. Qual a intensidade dessa cólica?',
      options: {
        'Fraca (um incômodo)': 'cramps_low',
        'Média (incomoda, mas dá pra seguir o dia)': 'cramps_med',
        'Forte (preciso deitar)': 'cramps_high',
      },
    ),
    'cramps_low': QuestionNode(
      id: 'cramps_low',
      question: 'Você já tentou tomar um chá quentinho hoje?',
      options: {
        'Sim, já tomei': 'end_cramps_tea_yes',
        'Vou fazer isso agora!': 'end_cramps_tea_no',
      },
    ),
    'cramps_med': QuestionNode(
      id: 'cramps_med',
      question:
          'Uma bolsa de água quente pode ajudar muito. Você tem uma por perto?',
      options: {
        'Sim, vou usar': 'end_cramps_water_yes',
        'Não tenho, vou tentar um banho quente': 'end_cramps_water_no',
      },
    ),
    'cramps_high': QuestionNode(
      id: 'cramps_high',
      question: 'Você costuma tomar alguma medicação para cólicas fortes?',
      options: {
        'Sim, já tomei meu remédio de costume': 'end_cramps_meds_yes',
        'Ainda não tomei': 'end_cramps_meds_no',
        'Prefiro tentar opções naturais primeiro': 'cramps_high_natural',
      },
    ),
    'cramps_high_natural': QuestionNode(
      id: 'cramps_high_natural',
      question: 'Entendido. Que tal alongamentos suaves focados na pelve?',
      options: {
        'Vou tentar': 'end_cramps_stretch_yes',
        'Estou com muita dor para me mexer': 'end_cramps_stretch_no',
      },
    ),
    'pain_head': QuestionNode(
      id: 'pain_head',
      question:
          'Dor de cabeça é difícil. Você acha que bebeu água suficiente hoje?',
      options: {
        'Sim, bebi bastante': 'head_water_yes',
        'Acho que bebi pouco': 'head_water_no',
      },
    ),
    'head_water_yes': QuestionNode(
      id: 'head_water_yes',
      question: 'Pode ser tensão ou hormonal. Você está perto de menstruar?',
      options: {
        'Sim, deve descer nos próximos dias': 'end_head_hormonal',
        'Não, deve ser tensão do dia a dia': 'end_head_tension',
      },
    ),
    'head_water_no': QuestionNode(
      id: 'head_water_no',
      question:
          'A desidratação é uma causa comum de dor de cabeça. Consegue tomar 2 copos de água agora?',
      options: {
        'Sim, já peguei minha garrafa': 'end_head_hydrate',
        'Vou tentar, mas estou enjoada': 'end_head_nausea',
      },
    ),
    'pain_boobs': QuestionNode(
      id: 'pain_boobs',
      question:
          'A dor nos seios costuma indicar a fase lútea. Eles estão apenas sensíveis ou inchados também?',
      options: {
        'Só sensíveis ao toque': 'end_boobs_sensitive',
        'Sensíveis e inchados': 'boobs_swollen',
      },
    ),
    'boobs_swollen': QuestionNode(
      id: 'boobs_swollen',
      question:
          'Reduzir o consumo de sal e cafeína pode ajudar no inchaço. Como foi sua alimentação hoje?',
      options: {
        'Comi bastante sal/café': 'end_boobs_diet_bad',
        'Me alimentei super bem': 'end_boobs_diet_good',
      },
    ),
    'pain_back': QuestionNode(
      id: 'pain_back',
      question:
          'A dor na lombar pode irradiar das cólicas ou ser postural. Você trabalha muito tempo sentada?',
      options: {
        'Sim, o dia todo': 'back_sitting',
        'Não, acho que é do ciclo mesmo': 'end_back_cycle',
      },
    ),
    'back_sitting': QuestionNode(
      id: 'back_sitting',
      question:
          'Que tal levantar e dar uma boa espreguiçada e alongada nas costas agora?',
      options: {
        'Boa ideia, farei isso': 'end_back_stretch',
        'Não posso agora': 'end_back_wait',
      },
    ),
    'flow_mood': QuestionNode(
      id: 'flow_mood',
      question:
          'As emoções são como o clima, sempre mudam. O que você está sentindo mais forte?',
      options: {
        'Irritação / Raiva': 'mood_angry',
        'Tristeza / Vontade de chorar': 'mood_sad',
        'Ansiedade / Inquietação': 'mood_anxious',
        'Carente / Sensível': 'mood_needy',
      },
    ),
    'mood_angry': QuestionNode(
      id: 'mood_angry',
      question:
          'Respire fundo! Você sabe identificar se há um gatilho específico?',
      options: {
        'Sim, alguém me irritou': 'end_mood_angry_trigger',
        'Não, acordei assim (provavelmente hormônios)':
            'end_mood_angry_hormones',
      },
    ),
    'mood_sad': QuestionNode(
      id: 'mood_sad',
      question:
          'Tudo bem chorar se precisar. Quer conversar com alguém ou prefere ficar sozinha?',
      options: {
        'Quero ligar para uma amiga': 'end_mood_sad_friend',
        'Prefiro meu casulo e um filme triste': 'end_mood_sad_alone',
      },
    ),
    'mood_anxious': QuestionNode(
      id: 'mood_anxious',
      question:
          'A ansiedade acelera a gente. Topa fazer 1 minuto de respiração profunda comigo agora?',
      options: {
        'Sim, vamos lá (Inspira... Expira...)': 'end_mood_anxious_breathe',
        'Não consigo focar nisso agora': 'end_mood_anxious_nofocus',
      },
    ),
    'mood_needy': QuestionNode(
      id: 'mood_needy',
      question:
          'Um abraço faz falta nessas horas. Que tal se dar um mimo hoje?',
      options: {
        'Vou pedir minha comida favorita': 'end_mood_needy_food',
        'Vou tomar um banho demorado e cuidar da pele': 'end_mood_needy_spa',
      },
    ),
    'flow_energy': QuestionNode(
      id: 'flow_energy',
      question: 'A exaustão suga tudo. Como está o seu ciclo hoje?',
      options: {
        'Estou menstruada (Dias 1 a 3)': 'energy_mens',
        'Estou na TPM': 'energy_pms',
        'Estou em outra fase, mas não dormi bem': 'energy_sleep',
      },
    ),
    'energy_mens': QuestionNode(
      id: 'energy_mens',
      question:
          'É normal! O corpo gasta muita energia na descamação uterina. Você pode descansar hoje?',
      options: {
        'Sim, vou cancelar meus planos e deitar': 'end_energy_mens_rest',
        'Infelizmente tenho que trabalhar/estudar': 'energy_mens_work',
      },
    ),
    'energy_mens_work': QuestionNode(
      id: 'energy_mens_work',
      question:
          'Tente fazer pausas a cada 1 hora e comer algo nutritivo. Evite cafeína em excesso!',
      options: {'Entendido!': 'end_energy_mens_work_done'},
    ),
    'energy_pms': QuestionNode(
      id: 'energy_pms',
      question:
          'A queda do estrogênio antes da menstruação causa muito cansaço. Bateu desejo de doce também?',
      options: {
        'Muito! Quero chocolate': 'end_energy_pms_choc',
        'Não, só quero a minha cama': 'end_energy_pms_bed',
      },
    ),
    'energy_sleep': QuestionNode(
      id: 'energy_sleep',
      question:
          'O corpo cobra a falta de sono. Você consegue tirar um cochilo de 20 minutos à tarde?',
      options: {
        'Sim, vou tentar': 'end_energy_sleep_nap',
        'Não rola, vou ter que segurar até a noite': 'end_energy_sleep_push',
      },
    ),
    'track_flow_type': QuestionNode(
      id: 'track_flow_type',
      question: 'Como está o seu fluxo menstrual hoje?',
      options: {
        'Leve': 'flow_light',
        'Moderado': 'flow_medium',
        'Intenso': 'flow_heavy',
        'Apenas escape (Spotting)': 'flow_spotting',
        'Não estou menstruada': 'root',
      },
    ),
    'flow_heavy': QuestionNode(
      id: 'flow_heavy',
      question:
          'Fluxo intenso requer cuidado extra. Quantos absorventes/coletores você já trocou hoje?',
      options: {
        'Menos de 3': 'end_heavy_ok',
        'Entre 3 e 5': 'end_heavy_monitor',
        'Mais de 5 (preciso trocar toda hora)': 'heavy_alert',
      },
    ),
    'heavy_alert': QuestionNode(
      id: 'heavy_alert',
      question:
          'Atenção: se você precisa trocar a cada 1 ou 2 horas, isso pode ser uma hemorragia. Você está se sentindo fraca ou tonta?',
      options: {
        'Sim, estou muito tonta': 'end_heavy_doctor',
        'Não, estou me sentindo normal, apenas com muito fluxo':
            'end_heavy_hydrate',
      },
    ),
    'end_great_sleep_8': QuestionNode(
      id: 'end_great_sleep_8',
      question:
          'Registro salvo! Lembre-se: conhecer seu corpo é seu maior superpoder. Descanse e se cuide!',
      options: {'Voltar ao Início': 'root', 'Finalizar Registro': 'EXIT'},
    ),
    'end_great_sleep_68': QuestionNode(
      id: 'end_great_sleep_68',
      question:
          'Registro salvo! Lembre-se: conhecer seu corpo é seu maior superpoder. Descanse e se cuide!',
      options: {'Voltar ao Início': 'root', 'Finalizar Registro': 'EXIT'},
    ),
    'end_great_sleep_low': QuestionNode(
      id: 'end_great_sleep_low',
      question:
          'Registro salvo! Lembre-se: conhecer seu corpo é seu maior superpoder. Descanse e se cuide!',
      options: {'Voltar ao Início': 'root', 'Finalizar Registro': 'EXIT'},
    ),
    'end_great_cycle_yes': QuestionNode(
      id: 'end_great_cycle_yes',
      question:
          'Registro salvo! Lembre-se: conhecer seu corpo é seu maior superpoder. Descanse e se cuide!',
      options: {'Voltar ao Início': 'root', 'Finalizar Registro': 'EXIT'},
    ),
    'end_great_cycle_no': QuestionNode(
      id: 'end_great_cycle_no',
      question:
          'Registro salvo! Lembre-se: conhecer seu corpo é seu maior superpoder. Descanse e se cuide!',
      options: {'Voltar ao Início': 'root', 'Finalizar Registro': 'EXIT'},
    ),
    'end_great_exe_cardio': QuestionNode(
      id: 'end_great_exe_cardio',
      question:
          'Registro salvo! Lembre-se: conhecer seu corpo é seu maior superpoder. Descanse e se cuide!',
      options: {'Voltar ao Início': 'root', 'Finalizar Registro': 'EXIT'},
    ),
    'end_great_exe_force': QuestionNode(
      id: 'end_great_exe_force',
      question:
          'Registro salvo! Lembre-se: conhecer seu corpo é seu maior superpoder. Descanse e se cuide!',
      options: {'Voltar ao Início': 'root', 'Finalizar Registro': 'EXIT'},
    ),
    'end_great_exe_relax': QuestionNode(
      id: 'end_great_exe_relax',
      question:
          'Registro salvo! Lembre-se: conhecer seu corpo é seu maior superpoder. Descanse e se cuide!',
      options: {'Voltar ao Início': 'root', 'Finalizar Registro': 'EXIT'},
    ),
    'end_great_random_yes': QuestionNode(
      id: 'end_great_random_yes',
      question:
          'Registro salvo! Lembre-se: conhecer seu corpo é seu maior superpoder. Descanse e se cuide!',
      options: {'Voltar ao Início': 'root', 'Finalizar Registro': 'EXIT'},
    ),
    'end_great_random_no': QuestionNode(
      id: 'end_great_random_no',
      question:
          'Registro salvo! Lembre-se: conhecer seu corpo é seu maior superpoder. Descanse e se cuide!',
      options: {'Voltar ao Início': 'root', 'Finalizar Registro': 'EXIT'},
    ),
    'end_cramps_tea_yes': QuestionNode(
      id: 'end_cramps_tea_yes',
      question:
          'Registro salvo! Lembre-se: conhecer seu corpo é seu maior superpoder. Descanse e se cuide!',
      options: {'Voltar ao Início': 'root', 'Finalizar Registro': 'EXIT'},
    ),
    'end_cramps_tea_no': QuestionNode(
      id: 'end_cramps_tea_no',
      question:
          'Registro salvo! Lembre-se: conhecer seu corpo é seu maior superpoder. Descanse e se cuide!',
      options: {'Voltar ao Início': 'root', 'Finalizar Registro': 'EXIT'},
    ),
    'end_cramps_water_yes': QuestionNode(
      id: 'end_cramps_water_yes',
      question:
          'Excelente! A hidratação alivia cólicas, dores de cabeça e inchaço. Beba bastante água.',
      options: {'Voltar ao Início': 'root', 'Finalizar Registro': 'EXIT'},
    ),
    'end_cramps_water_no': QuestionNode(
      id: 'end_cramps_water_no',
      question:
          'Excelente! A hidratação alivia cólicas, dores de cabeça e inchaço. Beba bastante água.',
      options: {'Voltar ao Início': 'root', 'Finalizar Registro': 'EXIT'},
    ),
    'end_cramps_meds_yes': QuestionNode(
      id: 'end_cramps_meds_yes',
      question:
          'Registro salvo! Lembre-se: conhecer seu corpo é seu maior superpoder. Descanse e se cuide!',
      options: {'Voltar ao Início': 'root', 'Finalizar Registro': 'EXIT'},
    ),
    'end_cramps_meds_no': QuestionNode(
      id: 'end_cramps_meds_no',
      question:
          'Registro salvo! Lembre-se: conhecer seu corpo é seu maior superpoder. Descanse e se cuide!',
      options: {'Voltar ao Início': 'root', 'Finalizar Registro': 'EXIT'},
    ),
    'end_cramps_stretch_yes': QuestionNode(
      id: 'end_cramps_stretch_yes',
      question:
          'Registro salvo! Lembre-se: conhecer seu corpo é seu maior superpoder. Descanse e se cuide!',
      options: {'Voltar ao Início': 'root', 'Finalizar Registro': 'EXIT'},
    ),
    'end_cramps_stretch_no': QuestionNode(
      id: 'end_cramps_stretch_no',
      question:
          'Registro salvo! Lembre-se: conhecer seu corpo é seu maior superpoder. Descanse e se cuide!',
      options: {'Voltar ao Início': 'root', 'Finalizar Registro': 'EXIT'},
    ),
    'end_head_hormonal': QuestionNode(
      id: 'end_head_hormonal',
      question:
          'Registro salvo! Lembre-se: conhecer seu corpo é seu maior superpoder. Descanse e se cuide!',
      options: {'Voltar ao Início': 'root', 'Finalizar Registro': 'EXIT'},
    ),
    'end_head_tension': QuestionNode(
      id: 'end_head_tension',
      question:
          'Registro salvo! Lembre-se: conhecer seu corpo é seu maior superpoder. Descanse e se cuide!',
      options: {'Voltar ao Início': 'root', 'Finalizar Registro': 'EXIT'},
    ),
    'end_head_hydrate': QuestionNode(
      id: 'end_head_hydrate',
      question:
          'Excelente! A hidratação alivia cólicas, dores de cabeça e inchaço. Beba bastante água.',
      options: {'Voltar ao Início': 'root', 'Finalizar Registro': 'EXIT'},
    ),
    'end_head_nausea': QuestionNode(
      id: 'end_head_nausea',
      question:
          'Registro salvo! Lembre-se: conhecer seu corpo é seu maior superpoder. Descanse e se cuide!',
      options: {'Voltar ao Início': 'root', 'Finalizar Registro': 'EXIT'},
    ),
    'end_boobs_sensitive': QuestionNode(
      id: 'end_boobs_sensitive',
      question:
          'Registro salvo! Lembre-se: conhecer seu corpo é seu maior superpoder. Descanse e se cuide!',
      options: {'Voltar ao Início': 'root', 'Finalizar Registro': 'EXIT'},
    ),
    'end_boobs_diet_bad': QuestionNode(
      id: 'end_boobs_diet_bad',
      question:
          'Registro salvo! Lembre-se: conhecer seu corpo é seu maior superpoder. Descanse e se cuide!',
      options: {'Voltar ao Início': 'root', 'Finalizar Registro': 'EXIT'},
    ),
    'end_boobs_diet_good': QuestionNode(
      id: 'end_boobs_diet_good',
      question:
          'Registro salvo! Lembre-se: conhecer seu corpo é seu maior superpoder. Descanse e se cuide!',
      options: {'Voltar ao Início': 'root', 'Finalizar Registro': 'EXIT'},
    ),
    'end_back_cycle': QuestionNode(
      id: 'end_back_cycle',
      question:
          'Registro salvo! Lembre-se: conhecer seu corpo é seu maior superpoder. Descanse e se cuide!',
      options: {'Voltar ao Início': 'root', 'Finalizar Registro': 'EXIT'},
    ),
    'end_back_stretch': QuestionNode(
      id: 'end_back_stretch',
      question:
          'Registro salvo! Lembre-se: conhecer seu corpo é seu maior superpoder. Descanse e se cuide!',
      options: {'Voltar ao Início': 'root', 'Finalizar Registro': 'EXIT'},
    ),
    'end_back_wait': QuestionNode(
      id: 'end_back_wait',
      question:
          'Registro salvo! Lembre-se: conhecer seu corpo é seu maior superpoder. Descanse e se cuide!',
      options: {'Voltar ao Início': 'root', 'Finalizar Registro': 'EXIT'},
    ),
    'end_mood_angry_trigger': QuestionNode(
      id: 'end_mood_angry_trigger',
      question:
          'Registro salvo! Lembre-se: conhecer seu corpo é seu maior superpoder. Descanse e se cuide!',
      options: {'Voltar ao Início': 'root', 'Finalizar Registro': 'EXIT'},
    ),
    'end_mood_angry_hormones': QuestionNode(
      id: 'end_mood_angry_hormones',
      question:
          'Registro salvo! Lembre-se: conhecer seu corpo é seu maior superpoder. Descanse e se cuide!',
      options: {'Voltar ao Início': 'root', 'Finalizar Registro': 'EXIT'},
    ),
    'end_mood_sad_friend': QuestionNode(
      id: 'end_mood_sad_friend',
      question:
          'Registro salvo! Lembre-se: conhecer seu corpo é seu maior superpoder. Descanse e se cuide!',
      options: {'Voltar ao Início': 'root', 'Finalizar Registro': 'EXIT'},
    ),
    'end_mood_sad_alone': QuestionNode(
      id: 'end_mood_sad_alone',
      question:
          'Registro salvo! Lembre-se: conhecer seu corpo é seu maior superpoder. Descanse e se cuide!',
      options: {'Voltar ao Início': 'root', 'Finalizar Registro': 'EXIT'},
    ),
    'end_mood_anxious_breathe': QuestionNode(
      id: 'end_mood_anxious_breathe',
      question:
          'Registro salvo! Lembre-se: conhecer seu corpo é seu maior superpoder. Descanse e se cuide!',
      options: {'Voltar ao Início': 'root', 'Finalizar Registro': 'EXIT'},
    ),
    'end_mood_anxious_nofocus': QuestionNode(
      id: 'end_mood_anxious_nofocus',
      question:
          'Registro salvo! Lembre-se: conhecer seu corpo é seu maior superpoder. Descanse e se cuide!',
      options: {'Voltar ao Início': 'root', 'Finalizar Registro': 'EXIT'},
    ),
    'end_mood_needy_food': QuestionNode(
      id: 'end_mood_needy_food',
      question:
          'Registro salvo! Lembre-se: conhecer seu corpo é seu maior superpoder. Descanse e se cuide!',
      options: {'Voltar ao Início': 'root', 'Finalizar Registro': 'EXIT'},
    ),
    'end_mood_needy_spa': QuestionNode(
      id: 'end_mood_needy_spa',
      question:
          'Registro salvo! Lembre-se: conhecer seu corpo é seu maior superpoder. Descanse e se cuide!',
      options: {'Voltar ao Início': 'root', 'Finalizar Registro': 'EXIT'},
    ),
    'end_energy_mens_rest': QuestionNode(
      id: 'end_energy_mens_rest',
      question:
          'Permita-se descansar. Seu corpo está pedindo uma pausa e escutá-lo é essencial agora.',
      options: {'Voltar ao Início': 'root', 'Finalizar Registro': 'EXIT'},
    ),
    'end_energy_mens_work_done': QuestionNode(
      id: 'end_energy_mens_work_done',
      question:
          'Registro salvo! Lembre-se: conhecer seu corpo é seu maior superpoder. Descanse e se cuide!',
      options: {'Voltar ao Início': 'root', 'Finalizar Registro': 'EXIT'},
    ),
    'end_energy_pms_choc': QuestionNode(
      id: 'end_energy_pms_choc',
      question:
          'Registro salvo! Lembre-se: conhecer seu corpo é seu maior superpoder. Descanse e se cuide!',
      options: {'Voltar ao Início': 'root', 'Finalizar Registro': 'EXIT'},
    ),
    'end_energy_pms_bed': QuestionNode(
      id: 'end_energy_pms_bed',
      question:
          'Permita-se descansar. Seu corpo está pedindo uma pausa e escutá-lo é essencial agora.',
      options: {'Voltar ao Início': 'root', 'Finalizar Registro': 'EXIT'},
    ),
    'end_energy_sleep_nap': QuestionNode(
      id: 'end_energy_sleep_nap',
      question:
          'Registro salvo! Lembre-se: conhecer seu corpo é seu maior superpoder. Descanse e se cuide!',
      options: {'Voltar ao Início': 'root', 'Finalizar Registro': 'EXIT'},
    ),
    'end_energy_sleep_push': QuestionNode(
      id: 'end_energy_sleep_push',
      question:
          'Registro salvo! Lembre-se: conhecer seu corpo é seu maior superpoder. Descanse e se cuide!',
      options: {'Voltar ao Início': 'root', 'Finalizar Registro': 'EXIT'},
    ),
    'end_heavy_ok': QuestionNode(
      id: 'end_heavy_ok',
      question:
          'Registro salvo! Lembre-se: conhecer seu corpo é seu maior superpoder. Descanse e se cuide!',
      options: {'Voltar ao Início': 'root', 'Finalizar Registro': 'EXIT'},
    ),
    'end_heavy_monitor': QuestionNode(
      id: 'end_heavy_monitor',
      question:
          'Registro salvo! Lembre-se: conhecer seu corpo é seu maior superpoder. Descanse e se cuide!',
      options: {'Voltar ao Início': 'root', 'Finalizar Registro': 'EXIT'},
    ),
    'end_heavy_doctor': QuestionNode(
      id: 'end_heavy_doctor',
      question:
          'Recomendação médica: Por favor, procure um médico se os sintomas forem severos ou contínuos. A sua saúde vem em primeiro lugar.',
      options: {'Voltar ao Início': 'root', 'Finalizar Registro': 'EXIT'},
    ),
    'end_heavy_hydrate': QuestionNode(
      id: 'end_heavy_hydrate',
      question:
          'Excelente! A hidratação alivia cólicas, dores de cabeça e inchaço. Beba bastante água.',
      options: {'Voltar ao Início': 'root', 'Finalizar Registro': 'EXIT'},
    ),
  };
}
