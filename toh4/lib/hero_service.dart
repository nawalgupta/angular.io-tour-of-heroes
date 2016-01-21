import 'dart:async';

import 'package:angular2/core.dart';

import 'mock_heroes.dart';
import 'hero.dart';

@Injectable()
class HeroService {
  Future<List<Hero>> getHeroes() => new Future(() => mockHeroes);

  Future<List<Hero>> getHeroesSlowly() {
    return new Future.delayed(const Duration(seconds: 2), () => mockHeroes);
  }
}
