import 'package:flutter/material.dart';

enum IconTypeEnum {
  mail,
  check,
  close,
  error,
  user,
  lock,
  chevronDown,
  chevronUp,
  globe,
  heart,
  search,
  location,
  calendar,
  phone,
  email,
  home,
  work,
  school,
  shopping,
  food,
  sports,
  movie,
  book,
  car,
  plane,
  train,
  bus,
  bike,
  walk,
  settings,
  logout,
  bell,
  moreHoriz,
  edit,
  delete,
  share,
  // File uploader specific icons
  file,
  checkCircle,
  errorOutline,
  unknown;

  factory IconTypeEnum.fromJson(String? json) {
    try {
      return IconTypeEnum.values.firstWhere(
        (e) => e.toString().split('.').last == json,
        orElse: () => IconTypeEnum.unknown,
      );
    } catch (_) {
      return IconTypeEnum.unknown;
    }
  }

  String toJson() => toString().split('.').last;

  IconData? toIconData() {
    switch (this) {
      case IconTypeEnum.mail:
        return Icons.mail;
      case IconTypeEnum.check:
        return Icons.check;
      case IconTypeEnum.close:
        return Icons.close;
      case IconTypeEnum.error:
        return Icons.error;
      case IconTypeEnum.user:
        return Icons.person;
      case IconTypeEnum.lock:
        return Icons.lock;
      case IconTypeEnum.chevronDown:
        return Icons.keyboard_arrow_down;
      case IconTypeEnum.chevronUp:
        return Icons.keyboard_arrow_up;
      case IconTypeEnum.globe:
        return Icons.language;
      case IconTypeEnum.heart:
        return Icons.favorite;
      case IconTypeEnum.search:
        return Icons.search;
      case IconTypeEnum.location:
        return Icons.location_on;
      case IconTypeEnum.calendar:
        return Icons.calendar_today;
      case IconTypeEnum.phone:
        return Icons.phone;
      case IconTypeEnum.email:
        return Icons.email;
      case IconTypeEnum.home:
        return Icons.home;
      case IconTypeEnum.work:
        return Icons.work;
      case IconTypeEnum.school:
        return Icons.school;
      case IconTypeEnum.shopping:
        return Icons.shopping_cart;
      case IconTypeEnum.food:
        return Icons.restaurant;
      case IconTypeEnum.sports:
        return Icons.sports_soccer;
      case IconTypeEnum.movie:
        return Icons.movie;
      case IconTypeEnum.book:
        return Icons.book;
      case IconTypeEnum.car:
        return Icons.directions_car;
      case IconTypeEnum.plane:
        return Icons.flight;
      case IconTypeEnum.train:
        return Icons.train;
      case IconTypeEnum.bus:
        return Icons.directions_bus;
      case IconTypeEnum.bike:
        return Icons.directions_bike;
      case IconTypeEnum.walk:
        return Icons.directions_walk;
      case IconTypeEnum.settings:
        return Icons.settings;
      case IconTypeEnum.logout:
        return Icons.logout;
      case IconTypeEnum.bell:
        return Icons.notifications;
      case IconTypeEnum.moreHoriz:
        return Icons.more_horiz;
      case IconTypeEnum.edit:
        return Icons.edit;
      case IconTypeEnum.delete:
        return Icons.delete;
      case IconTypeEnum.share:
        return Icons.share;
      case IconTypeEnum.file:
        return Icons.insert_drive_file_outlined;
      case IconTypeEnum.checkCircle:
        return Icons.check_circle_outline;
      case IconTypeEnum.errorOutline:
        return Icons.error_outline;
      case IconTypeEnum.unknown:
        return null;
    }
  }

  static IconTypeEnum fromString(String name) {
    switch (name) {
      case 'mail':
        return IconTypeEnum.mail;
      case 'check':
        return IconTypeEnum.check;
      case 'close':
        return IconTypeEnum.close;
      case 'error':
        return IconTypeEnum.error;
      case 'user':
        return IconTypeEnum.user;
      case 'lock':
        return IconTypeEnum.lock;
      case 'chevron-down':
        return IconTypeEnum.chevronDown;
      case 'chevron-up':
        return IconTypeEnum.chevronUp;
      case 'globe':
        return IconTypeEnum.globe;
      case 'heart':
        return IconTypeEnum.heart;
      case 'search':
        return IconTypeEnum.search;
      case 'location':
        return IconTypeEnum.location;
      case 'calendar':
        return IconTypeEnum.calendar;
      case 'phone':
        return IconTypeEnum.phone;
      case 'email':
        return IconTypeEnum.email;
      case 'home':
        return IconTypeEnum.home;
      case 'work':
        return IconTypeEnum.work;
      case 'school':
        return IconTypeEnum.school;
      case 'shopping':
        return IconTypeEnum.shopping;
      case 'food':
        return IconTypeEnum.food;
      case 'sports':
        return IconTypeEnum.sports;
      case 'movie':
        return IconTypeEnum.movie;
      case 'book':
        return IconTypeEnum.book;
      case 'car':
        return IconTypeEnum.car;
      case 'plane':
        return IconTypeEnum.plane;
      case 'train':
        return IconTypeEnum.train;
      case 'bus':
        return IconTypeEnum.bus;
      case 'bike':
        return IconTypeEnum.bike;
      case 'walk':
        return IconTypeEnum.walk;
      case 'settings':
        return IconTypeEnum.settings;
      case 'logout':
        return IconTypeEnum.logout;
      case 'bell':
        return IconTypeEnum.bell;
      case 'more_horiz':
        return IconTypeEnum.moreHoriz;
      case 'edit':
        return IconTypeEnum.edit;
      case 'delete':
        return IconTypeEnum.delete;
      case 'share':
        return IconTypeEnum.share;
      case 'file':
        return IconTypeEnum.file;
      case 'check_circle':
        return IconTypeEnum.checkCircle;
      case 'error_outline':
        return IconTypeEnum.errorOutline;
      default:
        return IconTypeEnum.unknown;
    }
  }
}
