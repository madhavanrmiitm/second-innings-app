class Validators {
  static String? validateFullName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your full name';
    }
    return null;
  }

  static String? validateDOB(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select your date of birth';
    }
    return null;
  }

  static String? validateYoutubeUrl(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a YouTube video URL';
    }
    final uri = Uri.tryParse(value);
    if (uri == null || !uri.hasAbsolutePath || !uri.hasScheme) {
      return 'Please enter a valid URL';
    }
    if (!uri.host.contains('youtube.com') && !uri.host.contains('youtu.be')) {
      return 'Please enter a valid YouTube URL';
    }
    return null;
  }
}
