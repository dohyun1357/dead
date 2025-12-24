$aux_dir = 'latex.out';
$out_dir = 'latex.out';
$emulate_aux_dir = 1;

$pdf_mode = 1;
$interaction = 'nonstopmode';
$halt_on_error = 1;
$file_line_error_style = 1;

$pdflatex = 'pdflatex -synctex=1 -shell-escape';
$bibtex = 'bibtex -min-crossrefs=99 %O %B';

# Ensure local style files are found first.
$ENV{TEXINPUTS} = 'sty:' . ($ENV{TEXINPUTS} // '');
