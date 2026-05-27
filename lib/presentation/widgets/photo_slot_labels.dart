String photoSlotLabel(int slot) {
  switch (slot) {
    case 1:
      return 'Спереди';
    case 2:
      return 'Сзади';
    case 3:
      return 'Левый бок';
    case 4:
      return 'Правый бок';
    default:
      return 'Фото $slot';
  }
}
