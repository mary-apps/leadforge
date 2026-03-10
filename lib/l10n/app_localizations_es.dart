// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'LeadForge';

  @override
  String get aiPoweredLeadGen => 'Generación de leads con IA';

  @override
  String get signIn => 'Iniciar Sesión';

  @override
  String get signUp => 'Registrarse';

  @override
  String get email => 'Correo electrónico';

  @override
  String get password => 'Contraseña';

  @override
  String get forgotPassword => '¿Olvidaste tu contraseña?';

  @override
  String get alreadyHaveAccount => '¿Ya tienes cuenta? Inicia Sesión';

  @override
  String get dontHaveAccount => '¿No tienes cuenta? Regístrate';

  @override
  String get continueWithApple => 'Continuar con Apple';

  @override
  String get emailRequired => 'El correo es obligatorio';

  @override
  String get enterValidEmail => 'Ingresa un correo válido';

  @override
  String get passwordRequired => 'La contraseña es obligatoria';

  @override
  String get passwordTooShort =>
      'La contraseña debe tener al menos 6 caracteres';

  @override
  String get emailSent => 'Correo Enviado';

  @override
  String passwordResetSent(String email) {
    return 'Link de recuperación enviado a $email. Revisa tu bandeja.';
  }

  @override
  String get enterEmailFirst => 'Ingresa tu correo electrónico primero';

  @override
  String get ok => 'OK';

  @override
  String get or => 'O';

  @override
  String get scout => 'Buscar';

  @override
  String get pipeline => 'Pipeline';

  @override
  String get dashboard => 'Panel';

  @override
  String get settings => 'Ajustes';

  @override
  String get searchBusinesses => 'Buscar negocios...';

  @override
  String get suggestedNiches => 'Nichos Sugeridos';

  @override
  String searchesRemaining(int count) {
    return '$count búsquedas restantes';
  }

  @override
  String get businessDetail => 'Detalle del Negocio';

  @override
  String get analyzeBusiness => 'Analizar Negocio';

  @override
  String get aiAnalysis => 'Análisis IA';

  @override
  String get generateDemo => 'Generar Demo';

  @override
  String get createMessage => 'Crear Mensaje';

  @override
  String get businessNotFound => 'Negocio no encontrado';

  @override
  String get checkingWebsite => 'Verificando sitio web...';

  @override
  String get analyzingReviews => 'Analizando reseñas...';

  @override
  String get calculatingScore => 'Calculando puntuación...';

  @override
  String get buildDemoSite => 'Crear Sitio Demo';

  @override
  String get createDemoFor => 'Crear un sitio web demo para';

  @override
  String get chooseTemplate => 'Elegir Plantilla';

  @override
  String get generateDemoSite => 'Generar Sitio Demo';

  @override
  String get demoSiteCreated => '¡Sitio Demo Creado!';

  @override
  String get shareWithProspect => 'Comparte este link con tu prospecto';

  @override
  String get linkCopied => 'Link copiado al portapapeles';

  @override
  String get share => 'Compartir';

  @override
  String get open => 'Abrir';

  @override
  String get demoLimitReached => 'Límite de Demos Alcanzado';

  @override
  String get demoLimitMessage =>
      'Ya usaste tu demo gratuito este mes. Actualiza a Pro para demos ilimitados.';

  @override
  String get maybeLater => 'Quizás Después';

  @override
  String get upgradeToPro => 'Actualizar a Pro';

  @override
  String get createOutreachMessage => 'Crear Mensaje de Contacto';

  @override
  String get generateMessageFor => 'Generar mensaje para';

  @override
  String get outreachChannel => 'Canal de Contacto';

  @override
  String get tone => 'Tono';

  @override
  String get generateMessage => 'Generar Mensaje';

  @override
  String get messageGenerated => 'Mensaje Generado';

  @override
  String get regenerate => 'Regenerar';

  @override
  String get copy => 'Copiar';

  @override
  String get messageCopied => 'Mensaje copiado al portapapeles';

  @override
  String get proFeature => 'Función Pro';

  @override
  String get proFeatureMessage =>
      'La generación de mensajes con IA es una función Pro.';

  @override
  String get upgradeForPro => 'Actualiza a Pro para:';

  @override
  String get unlimitedAiMessages => 'Mensajes IA ilimitados';

  @override
  String get fourChannels => '4 canales de contacto';

  @override
  String get threeTones => '3 opciones de tono';

  @override
  String get bilingual => 'Bilingüe (EN/ES)';

  @override
  String get overview => 'Resumen';

  @override
  String get totalLeads => 'Total Leads';

  @override
  String get audited => 'Auditados';

  @override
  String get demosSent => 'Demos Enviados';

  @override
  String get closedDeals => 'Negocios Cerrados';

  @override
  String get revenueTracker => 'Seguimiento de Ingresos';

  @override
  String get totalMrr => 'MRR Total';

  @override
  String get weeklyActivity => 'Actividad Semanal';

  @override
  String get filterByStatus => 'Filtrar por Estado';

  @override
  String get allStages => 'Todas las Etapas';

  @override
  String get exportCsv => 'Exportar CSV';

  @override
  String get found => 'Encontrado';

  @override
  String get demoCreated => 'Demo Creado';

  @override
  String get contacted => 'Contactado';

  @override
  String get interested => 'Interesado';

  @override
  String get closed => 'Cerrado';

  @override
  String get lost => 'Perdido';

  @override
  String movedTo(String status) {
    return 'Movido a $status';
  }

  @override
  String get deleteBusiness => 'Eliminar Negocio';

  @override
  String removeFromPipeline(String name) {
    return '¿Eliminar $name del pipeline?';
  }

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Eliminar';

  @override
  String get businessRemoved => 'Negocio eliminado';

  @override
  String get noBusinessesInStage => 'No hay negocios en esta etapa';

  @override
  String get subscription => 'Suscripción';

  @override
  String get pro => 'Pro';

  @override
  String get free => 'Gratis';

  @override
  String get usageThisMonth => 'Uso Este Mes';

  @override
  String get searches => 'Búsquedas';

  @override
  String get audits => 'Auditorías';

  @override
  String get demos => 'Demos';

  @override
  String get unlimited => '∞';

  @override
  String get limitReached =>
      'Límite alcanzado. Actualiza a Pro para ilimitado.';

  @override
  String get language => 'Idioma';

  @override
  String get about => 'Acerca de';

  @override
  String get signOut => 'Cerrar Sesión';

  @override
  String get signOutConfirm => '¿Estás seguro de que quieres cerrar sesión?';

  @override
  String get restaurant => 'Restaurante';

  @override
  String get restaurantDesc => 'Perfecto para cafés, bares y restaurantes';

  @override
  String get professionalServices => 'Servicios Profesionales';

  @override
  String get professionalDesc => 'Abogados, contadores, consultores';

  @override
  String get healthBeauty => 'Salud y Belleza';

  @override
  String get healthBeautyDesc => 'Salones, spas, clínicas';

  @override
  String get professional => 'Profesional';

  @override
  String get casual => 'Casual';

  @override
  String get direct => 'Directo';

  @override
  String get emailChannel => 'Correo';

  @override
  String get whatsapp => 'WhatsApp';

  @override
  String get instagram => 'Instagram';

  @override
  String get phone => 'Teléfono';

  @override
  String get other => 'Otro';
}
