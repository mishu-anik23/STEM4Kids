import 'package:flutter/material.dart';

class ChallengeIconMapper {
  static IconData getIcon(String objectName) {
    switch (objectName.toLowerCase()) {
      // Light sources
      case 'sun':
        return Icons.wb_sunny;
      case 'lamp':
      case 'desk_lamp':
      case 'table_lamp':
        return Icons.light;
      case 'lightbulb':
      case 'light_bulb':
        return Icons.lightbulb;
      case 'torch':
      case 'flashlight':
        return Icons.flashlight_on;
      case 'candle':
      case 'candles':
      case 'birthday_candles':
        return Icons.local_fire_department;
      case 'firefly':
        return Icons.bug_report;
      case 'ceiling_light':
        return Icons.light;
      case 'string_lights':
        return Icons.celebration;
      case 'lantern':
        return Icons.outdoor_grill;
      case 'match':
      case 'campfire':
        return Icons.whatshot;
      case 'car_headlight':
        return Icons.directions_car;
      case 'phone_light':
        return Icons.smartphone;
      case 'tv':
        return Icons.tv;

      // Not light sources / general objects
      case 'moon':
        return Icons.nightlight_round;
      case 'mirror':
        return Icons.crop_square;
      case 'chair':
        return Icons.chair;
      case 'book':
        return Icons.menu_book;
      case 'table':
        return Icons.table_bar;
      case 'ball':
        return Icons.sports_basketball;
      case 'window':
        return Icons.window;
      case 'water':
        return Icons.water;

      // Day/Night objects
      case 'star':
      case 'stars':
        return Icons.star;
      case 'cloud':
        return Icons.cloud;
      case 'rain':
        return Icons.grain;

      // Shadow objects
      case 'shadow':
        return Icons.filter_drama;
      case 'tree':
        return Icons.park;
      case 'house':
        return Icons.house;
      case 'person':
        return Icons.person;

      // Hot/Cold objects
      case 'fire':
        return Icons.whatshot;
      case 'ice':
      case 'ice_cream':
        return Icons.ac_unit;
      case 'snow':
      case 'snowflake':
        return Icons.ac_unit;
      case 'oven':
      case 'stove':
        return Icons.microwave;
      case 'fridge':
      case 'refrigerator':
        return Icons.kitchen;
      case 'hot_drink':
      case 'coffee':
      case 'tea':
        return Icons.coffee;
      case 'cold_drink':
        return Icons.local_drink;

      // Push/Pull objects
      case 'door':
        return Icons.door_front_door;
      case 'wagon':
      case 'cart':
        return Icons.shopping_cart;
      case 'swing':
        return Icons.child_care;
      case 'slide':
        return Icons.trending_down;
      case 'magnet':
        return Icons.attractions;

      // Interactive scene objects
      case 'toy':
        return Icons.toys;
      case 'remote':
        return Icons.settings_remote;
      case 'shoes':
        return Icons.hiking;
      case 'jacket':
        return Icons.dry_cleaning;
      case 'hat':
        return Icons.face;
      case 'pencil':
        return Icons.edit;
      case 'eraser':
        return Icons.auto_fix_high;
      case 'notebook':
        return Icons.note;

      default:
        return Icons.help_outline;
    }
  }

  static Color getColor(String objectName) {
    switch (objectName.toLowerCase()) {
      case 'sun':
        return Colors.orange;
      case 'lamp':
      case 'desk_lamp':
      case 'table_lamp':
        return Colors.amber;
      case 'lightbulb':
      case 'light_bulb':
        return const Color(0xFFF9A825);
      case 'torch':
      case 'flashlight':
        return const Color(0xFFFFB300);
      case 'candle':
      case 'candles':
        return const Color(0xFFFF8A65);
      case 'firefly':
        return Colors.greenAccent;
      case 'moon':
        return Colors.blueGrey;
      case 'mirror':
        return Colors.grey;
      case 'fire':
      case 'campfire':
        return Colors.deepOrange;
      case 'ice':
      case 'snow':
      case 'snowflake':
        return Colors.lightBlue;
      case 'water':
        return Colors.blue;
      case 'star':
      case 'stars':
        return Colors.amber;
      case 'tree':
        return Colors.green;
      default:
        return Colors.blueGrey;
    }
  }
}
