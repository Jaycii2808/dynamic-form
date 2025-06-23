import 'package:flutter/material.dart';

enum IconEnum {
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
  share;

  static IconEnum? fromJson(String name) {
    switch (name) {
      case 'mail':
        return IconEnum.mail;
      case 'check':
        return IconEnum.check;
      case 'close':
        return IconEnum.close;
      case 'error':
        return IconEnum.error;
      case 'user':
        return IconEnum.user;
      case 'lock':
        return IconEnum.lock;
      case 'chevron-down':
        return IconEnum.chevronDown;
      case 'chevron-up':
        return IconEnum.chevronUp;
      case 'globe':
        return IconEnum.globe;
      case 'heart':
        return IconEnum.heart;
      case 'search':
        return IconEnum.search;
      case 'location':
        return IconEnum.location;
      case 'calendar':
        return IconEnum.calendar;
      case 'phone':
        return IconEnum.phone;
      case 'email':
        return IconEnum.email;
      case 'home':
        return IconEnum.home;
      case 'work':
        return IconEnum.work;
      case 'school':
        return IconEnum.school;
      case 'shopping':
        return IconEnum.shopping;
      case 'food':
        return IconEnum.food;
      case 'sports':
        return IconEnum.sports;
      case 'movie':
        return IconEnum.movie;
      case 'book':
        return IconEnum.book;
      case 'car':
        return IconEnum.car;
      case 'plane':
        return IconEnum.plane;
      case 'train':
        return IconEnum.train;
      case 'bus':
        return IconEnum.bus;
      case 'bike':
        return IconEnum.bike;
      case 'walk':
        return IconEnum.walk;
      case 'settings':
        return IconEnum.settings;
      case 'logout':
        return IconEnum.logout;
      case 'bell':
        return IconEnum.bell;
      case 'more_horiz':
        return IconEnum.moreHoriz;
      case 'edit':
        return IconEnum.edit;
      case 'delete':
        return IconEnum.delete;
      case 'share':
        return IconEnum.share;
      default:
        return null;
    }
  }

  IconData? mapToIconData() {
    switch (this) {
      case IconEnum.mail:
        return Icons.mail;
      case IconEnum.check:
        return Icons.check;
      case IconEnum.close:
        return Icons.close;
      case IconEnum.error:
        return Icons.error;
      case IconEnum.user:
        return Icons.person;
      case IconEnum.lock:
        return Icons.lock;
      case IconEnum.chevronDown:
        return Icons.keyboard_arrow_down;
      case IconEnum.chevronUp:
        return Icons.keyboard_arrow_up;
      case IconEnum.globe:
        return Icons.language;
      case IconEnum.heart:
        return Icons.favorite;
      case IconEnum.search:
        return Icons.search;
      case IconEnum.location:
        return Icons.location_on;
      case IconEnum.calendar:
        return Icons.calendar_today;
      case IconEnum.phone:
        return Icons.phone;
      case IconEnum.email:
        return Icons.email;
      case IconEnum.home:
        return Icons.home;
      case IconEnum.work:
        return Icons.work;
      case IconEnum.school:
        return Icons.school;
      case IconEnum.shopping:
        return Icons.shopping_cart;
      case IconEnum.food:
        return Icons.restaurant;
      case IconEnum.sports:
        return Icons.sports_soccer;
      case IconEnum.movie:
        return Icons.movie;
      case IconEnum.book:
        return Icons.book;
      case IconEnum.car:
        return Icons.directions_car;
      case IconEnum.plane:
        return Icons.flight;
      case IconEnum.train:
        return Icons.train;
      case IconEnum.bus:
        return Icons.directions_bus;
      case IconEnum.bike:
        return Icons.directions_bike;
      case IconEnum.walk:
        return Icons.directions_walk;
      case IconEnum.settings:
        return Icons.settings;
      case IconEnum.logout:
        return Icons.logout;
      case IconEnum.bell:
        return Icons.notifications;
      case IconEnum.moreHoriz:
        return Icons.more_horiz;
      case IconEnum.edit:
        return Icons.edit;
      case IconEnum.delete:
        return Icons.delete;
      case IconEnum.share:
        return Icons.share;
    }
  }
}
