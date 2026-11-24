import 'package:flutter/material.dart';

class Emotion {
  final String key, en, ur, emoji, desc, urDesc;
  final Color color;
  const Emotion(this.key, this.en, this.ur, this.emoji, this.color, this.desc, this.urDesc);
}

const emotions = <Emotion>[
  Emotion('happiness', 'Happiness', 'خوشی', '😊', Color(0xFFF5A524),
      'A positive feeling of joy, contentment and delight, often shown through celebration, gratitude and warm words.',
      'خوشی ایک مثبت جذبہ ہے جو مسرت، اطمینان اور شکر گزاری کے الفاظ میں جھلکتا ہے۔'),
  Emotion('sadness', 'Sadness', 'اداسی', '😢', Color(0xFF4F7CF0),
      'A feeling of sorrow, loss or disappointment, often expressed through longing, loneliness and tears.',
      'اداسی دکھ، جدائی اور محرومی کا احساس ہے جو تنہائی اور آنسوؤں کے الفاظ میں ظاہر ہوتا ہے۔'),
  Emotion('anger', 'Anger', 'غصہ', '😠', Color(0xFFEF4B4B),
      'A strong reaction to injustice, betrayal or frustration, usually with harsh, accusing or demanding language.',
      'غصہ ناانصافی، دھوکے یا مایوسی پر شدید ردعمل ہے جو سخت اور الزامی لہجے میں سامنے آتا ہے۔'),
  Emotion('fear', 'Fear', 'خوف', '😨', Color(0xFF8B5CF6),
      'An emotional response to danger or uncertainty, expressed through worry, panic and anxious words.',
      'خوف کسی خطرے یا بے یقینی پر پیدا ہونے والا جذبہ ہے جو گھبراہٹ اور پریشانی میں ظاہر ہوتا ہے۔'),
  Emotion('surprise', 'Surprise', 'حیرت', '😲', Color(0xFFEC4899),
      'A sudden reaction to something unexpected, shown through exclamations and disbelief.',
      'حیرت کسی غیر متوقع بات پر اچانک ردعمل ہے جو تعجب اور بے یقینی کے کلمات میں جھلکتا ہے۔'),
  Emotion('disgust', 'Disgust', 'نفرت', '🤢', Color(0xFF22A06B),
      'A feeling of strong disapproval or revulsion toward something unpleasant or morally offensive.',
      'نفرت یا کراہت کسی ناپسندیدہ چیز یا بات کے خلاف شدید بیزاری کا اظہار ہے۔'),
  Emotion('neutral', 'Neutral', 'غیر جانبدار', '😐', Color(0xFF64748B),
      'Plain, factual language with no strong emotional charge, such as schedules, facts and statements.',
      'غیر جانبدار جملے سادہ اور معلوماتی ہوتے ہیں جن میں کوئی نمایاں جذباتی کیفیت نہیں ہوتی۔'),
];

Emotion emo(String key) => emotions.firstWhere((e) => e.key == key, orElse: () => emotions.last);

const samples = <(String, String)>[
  ('happiness', 'آج میں بہت خوش ہوں، میری دعا قبول ہو گئی!'),
  ('sadness', 'ان کے جانے کے بعد گھر سونا سونا لگتا ہے۔'),
  ('anger', 'تم نے مجھ سے جھوٹ کیوں بولا؟ مجھے بہت غصہ آ رہا ہے!'),
  ('fear', 'اندھیرے میں قدموں کی آواز سن کر میں ڈر گئی۔'),
  ('surprise', 'واہ! مجھے یقین ہی نہیں آ رہا کہ تم آ گئے!'),
  ('disgust', 'یہ گندگی دیکھ کر مجھے گھن آ رہی ہے۔'),
  ('neutral', 'کل صبح دس بجے میٹنگ ہے۔'),
];

const roles = ['Student', 'Researcher', 'Media Analyst', 'Teacher', 'Content Writer', 'Developer', 'Other'];
