# IdealLife - симулятор эволюции ботов

В симуляторе можно наблюдать за развитием ботов<br>
Можно сохранять/изменять геном бота<br>
Создавать различные миры
# Устройства мира
Мир представляет собой 2D плоскость разбитую на ячейки<br>
В начале мир заселяется N-ое количество ботов способных к:
- фотосинтезу
- поеданию друг друга
- передачи энергии
- передвижению
- размножению

# Боты
<b>Энергия</b><br>
Бот восполняет энергию фотосинтезом или поедая других ботов, а тратит каждый ход n-энергии<br>
<br>
<b>Геном</b><br>
Всё поведение бота заключено в геноме, он не меняется на протяжении его жизни.<br>
В геноме с шансом в 25% при размножении меняется 1 из 36 генов<br>
<br>
<b>Мутации</b> могут повлиять на выживаемость как положительно, так и отрицательно<br>
В первом случае бот с большей вероятностью сможет размножиться, которое может вытеснить менее приспособленное поколение<br>
Во втором случае бот либо умрёт, либо с меньшей вероятностью оставит потомство<br>
<br>
<b>Смерть</b><br>
Бот после смерти оставляет на своем месте плоть, которую могут съесть другие боты и восполнить энергию<br>
Жизнь бота не ограничена по времени, но умирает в случае:
- исчерпания энергии
- поедания другим ботом
- если при делении нет свободного места вокруг бота<br>
# Скачать
https://play.google.com/store/apps/details?id=com.levstudio.idollive<br>
<br>
Приложение созданно как хобби<br>
Создано на <b>фрейворке Solar2D</b><br>

