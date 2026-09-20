extends RefCounted
const Loot = preload("res://scripts/loot.gd")
static func paint(control: Control, rect: Rect2, item: Dictionary, animated: bool = true):
	var tier: int = item.get("tier",0)
	if tier < 2: return
	var color = Loot.color(item)
	var phase = Time.get_ticks_msec()*0.001
	var strength = 0.22+(tier-2)*0.14
	if tier >= 4 and animated: strength *= 0.85+sin(phase*2.8)*0.15
	var glow = StyleBoxFlat.new()
	glow.bg_color = Color.TRANSPARENT
	glow.border_color = Color(color,strength)
	glow.set_border_width_all(2)
	glow.draw_center = false
	for spread in range(2,5+(tier-2)*3,2):
		control.draw_rect(rect.grow(spread*0.5),Color(color,strength/(spread+1)),false,2)
	control.draw_style_box(glow,rect.grow(-2))
	if tier == 5:
		control.draw_rect(rect.grow(-4),Color("fff0b4"),false,1.5)
	if tier >= 4 and animated:
		var perimeter = 2*(rect.size.x+rect.size.y)
		for offset in [0.0,0.5]:
			var t = fmod(phase*65+offset*perimeter,perimeter)
			var p = rect.position
			if t < rect.size.x: p += Vector2(t,0)
			elif t < rect.size.x+rect.size.y: p += Vector2(rect.size.x,t-rect.size.x)
			elif t < rect.size.x*2+rect.size.y: p += Vector2(rect.size.x*2+rect.size.y-t,rect.size.y)
			else: p += Vector2(0,perimeter-t)
			control.draw_circle(p,4,Color(color,0.25))
			control.draw_circle(p,1.5,Color("fff0fd"))
