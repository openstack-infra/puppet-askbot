# Define: askbot::helper::template_file
#
# Define a setup_templates file, cloned from a template
# directory.
#
# Parameters:
#   - $template_path: root directory of setup_templates.
#   - $dest_dir: destination directory of target files.
#
define askbot::site::setup_template (
  $template_path,
  $dest_dir,
) {
  file { "${dest_dir}/${name}":
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    source  => "${template_path}/${name}",
  }
}
