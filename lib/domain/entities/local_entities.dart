// В проекте уже используются Drift-модели как DTO между слоями.
// Чтобы presentation не импортировал data/repositories, экспортируем только
// типы сущностей, необходимые для экранов.
export '../../data/local/app_database.dart'
    show
        BodyMeasurement,
        CustomProduct,
        Food,
        LocalUser,
        Meal,
        MealItem,
        ProgressPhoto,
        Recipe,
        RecipeIngredient;
