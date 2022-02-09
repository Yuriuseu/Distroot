/* See LICENSE file for copyright and license details. */
/* Default settings; can be overriden by command line. */

static int topbar = 1;                      /* -b  option; if 0, dmenu appears at bottom     */
/* -fn option overrides fonts[0]; default X11 font or font set */
static const char *fonts[] = {
	"Droid Sans Mono:pixelsize=13:antialias=true:autohint=true",
	"Material Design Icons:pixelsize=13:antialias=true:autohint=true"
};
static const char *prompt = "󰞷";      /* -p  option; prompt to the left of input field */
static const char *prevsymbol = "󰨂";
static const char *nextsymbol = "󰨃";
static const char colorprimary[] = "#2e3440";
static const char colorsecondary[] = "#8fbcbb";
static const char colortertiary[] = "#ebcb8b";
static const char colortext[] = "#ffffff";
static const char *colors[SchemeLast][2] = {
	/*     fg         bg       */
	[SchemeNorm] = { colortext, colorprimary },
	[SchemeSel] = { colortext, colorsecondary },
	[SchemeSelHighlight] = { colortertiary, colorsecondary },
	[SchemeNormHighlight] = { colortertiary, colorprimary },
	[SchemeOut] = { "#000000", "#00ffff" },
};
/* -l option; if nonzero, dmenu uses vertical list with given number of lines */
static unsigned int lines = 0;
/*
 * Characters not considered part of a word while deleting words
 * for example: " /?\"&[]"
 */
static const char worddelimiters[] = " ";
