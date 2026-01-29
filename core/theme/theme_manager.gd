extends Node

# Core palette: Kintsugi Midnight
const BACKGROUND: Color = Color('060045')      # Deep Twilight
const FOCUS_A: Color = Color('DCAE1D')         # Metalic Gold
const FOCUS_B: Color = Color('D93D83')         # Rose Punch
const GRID: Color = Color('2B3B4F')            # Charcoal Blue
const TEXT_PRIMARY: Color = Color('E4E8F1')    # Alice Blue
const TEXT_SECONDARY: Color = Color('99C9D6')  # Light Blue

# Accents
const GREEN: Color = Color('255C43')           # Emerald Depths
const RED: Color = Color('A4161A')             # Mahogany Red
const BLUE: Color = Color('2C279A')            # International Klein Blue
const PURPLE: Color = Color('54038A')          # Indigo
const YELLOW: Color = Color('D19200')          # Harvest Gold
const ORANGE: Color = Color('B85000')          # Autumn Ember
const ACCENTS: Array = [GREEN, RED, BLUE, PURPLE, YELLOW, ORANGE]

func _ready():
	RenderingServer.set_default_clear_color(BACKGROUND)
	print("ThemeManager initialized with Kintsugi Midnight palette.")
