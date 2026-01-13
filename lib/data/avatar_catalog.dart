import 'package:flutter/material.dart';

class AvatarData {
  const AvatarData({
    required this.key,
    required this.imageUrl,
    required this.accent,
    this.accessibilityLabel,
  });

  final String key;
  final String imageUrl;
  final Color accent;
  final String? accessibilityLabel;
}

class AvatarCatalog {
  AvatarCatalog._();

  static const List<AvatarData> _avatars = [
    AvatarData(
      key: 'bear',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuB5JPm-Xp5hbxsy1GDvKeuFEHvEFD8CpaJZfsqzd7bkddknXiYI2tNutnl3Mbwn28G6rN-Kkq-syWBJr4ciSreCfAR7YABe3K3hiCMTD-HuaZuZ8HuKK_1l6K7qXQFh_eg7N5-ND_gGVL1vi6J5bz7paEkAeQAYBeOl3ReHUBZuWsljcQaIPWz5AlCcyMwRX1hPz8EXoB2-R1paRX84P6px3dXjWhUHkz_-XilNrywJ9sqHoJz7TN7QmClLWbAbI5IWjxOJmI1Egyg',
      accent: Color(0xFFFFA726),
      accessibilityLabel: 'Bear avatar',
    ),
    AvatarData(
      key: 'bunny',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCpTUWGqHdjIORnoT8L37oVghPsbKtipOE5PqA-5_c7FEzfN_UbEblPjq1BOvoSToYzHUADprzR-bIVKtkEv0zLPJyFyywfir335e7EZjtVCPQ8VpAdLGNc-XcNJ-vlhd55HS8DxjvI-CkQwEw8vsHhOn-5n4-gGE5Y5kTWDwVvykioMSI5DHAxdG8gBE3H6LeIC44rutUX0Wx9sU1Xkc81aYoWRmRS5i9vMPjR_HkLLqglrRduFvR2pPDNNTYKbx7tbMMwQ6sIRwM',
      accent: Color(0xFFF48FB1),
      accessibilityLabel: 'Bunny avatar',
    ),
    AvatarData(
      key: 'fox',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAHEVz_5oAKTLUUWcFaTtHZAUtShT-8cj4sHA5BbQOiTLhKdFMbK1FyXz3j26kZjeAUDOxvVL29XKFz0RK3mbW6SOn9YFhZ7KjBeEv8NoXAfwcpUM2x-LsUuiuROcs4Lyos4yG2Uy-r4dR4kufIlcXizNY9RfCQLLL5blIRMoKNoTzqXcG52m3iTLkRNflWccxdf6cI2g-kxJXDocc0o7BlF7GuFeGH77Wo5Du_nSveIma0AH1XOLlKTtYZZZ11bVJUfjjMnyeVQmc',
      accent: Color(0xFFFF7043),
      accessibilityLabel: 'Fox avatar',
    ),
    AvatarData(
      key: 'alien',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDOmlNu74RptIvFyULU5Jy7duuBlj-1sHP6tv-Vpvfax4r9NTwvZDxEx3BWNh7IbFzCrn06i4nTBi9XzTIbeGirFcOtGUOwMwfUqb9lzbitcRWnt2uO92dnSj7s2d1tcwnGELhydF-Lb8-CGFT7cNQHJlu6_UDuM8HpoCkCSsbWqJw8CzP6z9bt0vbPEIjeuk-OlPjyx7BRj3OQpq4bRX2eKZaJW0ZeZdn4oxXQj8I_LvP0D9OlZ6z25EXb9T92BpmwQi5JxkUVsDQ',
      accent: Color(0xFF4FC3F7),
      accessibilityLabel: 'Alien avatar',
    ),
    AvatarData(
      key: 'monster',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCv7bwX7DwRNj-5qH6EuRNRyNLMOyoTBDTx6VuMyjIHIjgJ0KndinBXEEFX3byZ6AxCijMVxVECjltVJ3hPqlJLjEJtQ5rjFn2tfrSKeuj8SzDUyctnWoAlsZV7WvFo3NQPnnjd200LolaWDkNpmCmUqxEY6mckqXfl-zZ3P1ZLmgmjB6hNkW0vLcdXmzPHjUg353cRx0pTvRmTDZKETV3s1aBS7UZueyOI5euk67NrjQp1iNLoG-R8hFx9Y9AEMU--O-eDP2JOB9Y',
      accent: Color(0xFFBA68C8),
      accessibilityLabel: 'Monster avatar',
    ),
  ];

  static List<String> get keys => _avatars.map((avatar) => avatar.key).toList();

  static AvatarData byKey(String key) {
    return _avatars.firstWhere(
      (avatar) => avatar.key == key,
      orElse: () => _avatars.first,
    );
  }
}
