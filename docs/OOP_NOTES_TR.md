# Ödevin kodunu anlama rehberi

## Uygulama açılınca ne oluyor?

`main()` uygulamayı başlatır. `SmartHomeApp` koyu temayı tanımlar ve `HomePage` ekranını açar. `HomePage.initState()` bir lamba, bir termostat ve bir hoparlör oluşturur. Bu işlem `build()` içinde yapılmaz; böylece her tuşa basışta yeni cihaz yaratılmaz.

Cihazlar `List<SmartDevice>` içinde tutulur. Listedeki nesnelerin gerçek türleri farklıdır ama ortak üst sınıfları sayesinde birlikte kullanılabilirler. Örneğin aynı döngüde hepsinin `connect()` metodu çağrılır. `DeviceCard`, hangi cihazı alırsa o cihazın `getStatus()` uygulamasını çalıştırır. Bu, çok biçimliliktir (polymorphism).

## Sınıflar ve soyutlama

`SmartDevice` soyut sınıftır. Ad, oda, bağlantı bilgisi ve ortak sayaç davranışını içerir. Doğrudan `SmartDevice` nesnesi oluşturulamaz. Gövdesiz `getStatus()` ve `performAction()` metotlarının uygulaması alt sınıflara bırakılır.

`SmartLight`, `Thermostat` ve `SmartSpeaker`, `extends SmartDevice` ile ortak bilgileri miras alır. `@override` ile ortak metotları kendilerine göre uygularlar. Örneğin `performAction()` lambayı açıp kapatırken hoparlörün oynatma durumunu değiştirir.

Alanların başındaki `_`, Dart'ta kütüphane düzeyinde gizlilik sağlar. Dış kod parlaklığı doğrudan değiştirmek yerine `setBrightness()` metodunu kullanır; bu metot değeri izin verilen aralıkta tutar.

## Constructor, this ve super

`SmartLight(name: ..., room: ...)`, sınıfın isimsiz constructor'ını çağırır. `Thermostat.comfort(room: ...)` ise isimlendirilmiş constructor'dır. İçindeki `this(...)` çağrısı aynı sınıfın isimsiz constructor'ına yönlendirir.

`this.name` ve `this.room`, constructor parametrelerini nesnenin alanlarına atar. `super.name` ve `super.room` ise parametreleri üst sınıfın constructor'ına aktarır.

## Interface ile mixin arasındaki fark

`Connectable`, cihazların bağlantı için hangi metotları sunacağını belirleyen bir sözleşmedir. `SmartDevice implements Connectable` diyerek `connect()` ve `disconnect()` metotlarını uygular. Üç cihaz türü bu uygulamayı miras alır; dolayısıyla üçü de `Connectable` sözleşmesini karşılar. Buradaki bağlantı gerçek ağ bağlantısı değil, demo durumudur.

`Schedulable` ise paylaşılabilen hazır davranıştır. `SmartLight extends SmartDevice with Schedulable` ifadesi lambaya zamanlayıcı ekler. `Timer` bir dakika sonra lambayı kapatır; `clearSchedule()` bekleyen işlemi iptal eder. Sayfa kapatılırken `dispose()` zamanlayıcıyı temizler.

## static sayaç neden gerekli?

`SmartDevice._totalDevices`, her nesnenin ayrı bir kopyasına sahip olduğu bir alan değildir; sınıfın paylaşılan alanıdır. Üst sınıf constructor'ı her yeni cihazda sayacı bir artırır. Arayüz `SmartDevice.totalDevices` getter'ından bu değeri okur. Bağlantı açıp kapatmak ya da ekranı tekrar çizmek sayacı artırmaz.

## Tuşa basınca ekran nasıl güncellenir?

Kontrol önce modelin durumunu değiştirir. `setState()` Flutter'a ekranı yeniden çizmesini söyler. Kartın durum yazısı ve değeri yeniden modelden okunur. Cihazlar aynı nesneler olarak kalır.

Termostatın Heating/Cooling/Comfort durumu 22 derece referansına göre hesaplanan basit bir simülasyondur. Hoparlör ses dosyası çalmaz; oynatma durumu ve ses seviyesi model üzerinde değişir.
