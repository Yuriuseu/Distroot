/* See LICENSE file for copyright and license details. */

/* appearance */
static char* status = " 󰍜 ";
static const unsigned int borderpx  = 1;        /* border pixel of windows */
static const unsigned int gappx     = 5;        /* gaps between windows */
static const unsigned int snap      = 32;       /* snap pixel */
static const int showbar            = 1;        /* 0 means no bar */
static const int topbar             = 1;        /* 0 means bottom bar */
static const char *fonts[]          = {
	"Droid Sans Mono:pixelsize=13:antialias=true:autohint=true",
	"Material Design Icons:pixelsize=13:antialias=true:autohint=true"
};
static const char colorprimary[]    = "#2e3440";
static const char colorsecondary[]  = "#8fbcbb";
static const char colortext[]       = "#ffffff";
static const char *colors[][3]      = {
	/*               fg         bg         border   */
	[SchemeNorm] = { colortext, colorprimary, colorprimary },
	[SchemeSel]  = { colortext, colorsecondary, colorsecondary },
};

/* tagging */
static const char *tags[] = { "󰎤", "󰎧", "󰎪", "󰎭", "󰎱", "󰎳", "󰎶", "󰎹", "󰎼" };

static const Rule rules[] = {
	/* xprop(1):
	 *	WM_CLASS(STRING) = instance, class
	 *	WM_NAME(STRING) = title
	 */
	/* class               instance    title                       tags mask     isfloating   monitor */
	{ "",                  NULL,       NULL,                       0,                 0,           -1 }
};

/* layout(s) */
static const float mfact     = 0.55; /* factor of master area size [0.05..0.95] */
static const int nmaster     = 1;    /* number of clients in master area */
static const int resizehints = 0;    /* 1 means respect size hints in tiled resizals */

static const Layout layouts[] = {
	/* symbol     arrange function */
	{ "󰙀",        tile },    /* first entry is default */
	{ "󱋬",        NULL },    /* no layout function means floating behavior */
	{ "󰄶",        monocle },
};

/* key definitions */
#define MODKEY Mod1Mask
#define TAGKEYS(KEY,TAG) \
	{ MODKEY,                       KEY,      view,           {.ui = 1 << TAG} }, \
	{ MODKEY|ControlMask,           KEY,      toggleview,     {.ui = 1 << TAG} }, \
	{ MODKEY|ShiftMask,             KEY,      tag,            {.ui = 1 << TAG} }, \
	{ MODKEY|ControlMask|ShiftMask, KEY,      toggletag,      {.ui = 1 << TAG} },

/* helper for spawning shell commands in the pre dwm-5.0 fashion */
#define SHCMD(cmd) { .v = (const char*[]){ "/bin/sh", "-c", cmd, NULL } }

/* commands */
static char dmenumon[2] = "0"; /* component of dmenucmd, manipulated in spawn() */
static const char *dmenucmd[] = { "dmenu_run", "-m", dmenumon, NULL };

static Key keys[] = {
	/* modifier                     key                        function        argument */
	{ MODKEY,                       XK_p,                      spawn,          {.v = dmenucmd } },
	{ MODKEY,                       XK_b,                      togglebar,      {0} },
	{ MODKEY,                       XK_j,                      focusstack,     {.i = +1 } },
	{ MODKEY,                       XK_k,                      focusstack,     {.i = -1 } },
	{ MODKEY,                       XK_i,                      incnmaster,     {.i = +1 } },
	{ MODKEY,                       XK_d,                      incnmaster,     {.i = -1 } },
	{ MODKEY,                       XK_h,                      setmfact,       {.f = -0.05} },
	{ MODKEY,                       XK_l,                      setmfact,       {.f = +0.05} },
	{ MODKEY,                       XK_Return,                 zoom,           {0} },
	{ MODKEY,                       XK_Tab,                    view,           {0} },
	{ MODKEY,                       XK_c,                      killclient,     {0} },
	{ MODKEY,                       XK_t,                      setlayout,      {.v = &layouts[0]} },
	{ MODKEY,                       XK_f,                      setlayout,      {.v = &layouts[1]} },
	{ MODKEY,                       XK_m,                      setlayout,      {.v = &layouts[2]} },
	{ MODKEY,                       XK_space,                  setlayout,      {0} },
	{ MODKEY|ShiftMask,             XK_space,                  togglefloating, {0} },
	{ MODKEY|ShiftMask,             XK_f,                      togglefullscr,  {0} },
	{ MODKEY,                       XK_0,                      view,           {.ui = ~0 } },
	{ MODKEY|ShiftMask,             XK_0,                      tag,            {.ui = ~0 } },
	{ MODKEY,                       XK_comma,                  focusmon,       {.i = -1 } },
	{ MODKEY,                       XK_period,                 focusmon,       {.i = +1 } },
	{ MODKEY|ShiftMask,             XK_comma,                  tagmon,         {.i = -1 } },
	{ MODKEY|ShiftMask,             XK_period,                 tagmon,         {.i = +1 } },
	{ MODKEY,                       XK_minus,                  setgaps,        {.i = -1 } },
	{ MODKEY,                       XK_equal,                  setgaps,        {.i = +1 } },
	{ MODKEY|ShiftMask,             XK_equal,                  setgaps,        {.i = 0  } },
	{ MODKEY|ControlMask|ShiftMask, XK_q,                      quit,           {0} },
	TAGKEYS(                        XK_1,                      0)
	TAGKEYS(                        XK_2,                      1)
	TAGKEYS(                        XK_3,                      2)
	TAGKEYS(                        XK_4,                      3)
	TAGKEYS(                        XK_5,                      4)
	TAGKEYS(                        XK_6,                      5)
	TAGKEYS(                        XK_7,                      6)
	TAGKEYS(                        XK_8,                      7)
	TAGKEYS(                        XK_9,                      8)
};

/* button definitions */
/* click can be ClkTagBar, ClkLtSymbol, ClkStatusText, ClkWinTitle, ClkClientWin, or ClkRootWin */
static Button buttons[] = {
	/* click                event mask                    button          function        argument */
	{ ClkStatusText,        0,                            Button1,        spawn,          {.v = dmenucmd } },
	{ ClkLtSymbol,          0,                            Button1,        setlayout,      {0} },
	{ ClkWinTitle,          0,                            Button1,        zoom,           {0} },
	{ ClkClientWin,         MODKEY,                       Button1,        movemouse,      {0} },
	{ ClkClientWin,         MODKEY|ShiftMask,             Button1,        resizemouse,    {0} },
	{ ClkClientWin,         MODKEY|ControlMask|ShiftMask, Button1,        togglefloating, {0} },
	{ ClkTagBar,            0,                            Button1,        view,           {0} },
	{ ClkTagBar,            MODKEY,                       Button1,        toggleview,     {0} },
	{ ClkTagBar,            MODKEY|ShiftMask,             Button1,        tag,            {0} },
	{ ClkTagBar,            MODKEY|ControlMask|ShiftMask, Button1,        toggletag,      {0} },
};
