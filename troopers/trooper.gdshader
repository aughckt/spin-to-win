shader_type canvas_item;

uniform float progress: hint_range(0.0, 1.0, 0.01);
uniform float strength: hint_range(0.0, 20.0, 0.1);

uniform float y_threshold: hint_range(0.0, 1.0, 0.001);

uniform vec3 grey: source_color;

uniform float border: hint_range(0.0, 1.0, 0.1);

vec4 get_col(vec2 uv, vec2 pixel_size) {
	//if (int(trunc(pixel_size.y * 18.)) == 0) {
	//	return vec4(0., 0., 1., 1.);
	//}
	
	vec2 pixel = uv * (1. / pixel_size);
	float border_y = border * (1. / (1./18.));//pixel_size.x);
	
	vec4 col = vec4(0.);
	
	if (int(pixel.y) == 9) {//int(border_y)) {
		col.r = 1.;
		col.a = 1.;
	}
	
	return col;
}

void fragment() {
	vec3 col = COLOR.rgb;
	
	
	
	
	//vec3 evil = vec3(1) - col;
	//col -= evil * progress * strength;
	
	//col = mix(col, grey, progress);
	
	//this is also kind of fucked, maybe it has to do with it being an animated sprite
	/*if (UV.y > 1. - y_threshold) {
		vec3 mono = vec3(col.g);
		col = mix(col, mono, progress);
	}*/
	
	//trying to make it pixel perfect
	//this is really weird, my math must be wrong somewhere but it works for the uv but not the threshold
	float pixels_y = 1. / TEXTURE_PIXEL_SIZE.y;
	int pixel_pos_y = int(trunc(pixels_y * UV.y));
	
	float y = float(pixel_pos_y);
	
	//really dumb: the image is 17x17 and so of course 0.17 is equal 50% because why not
	//and also it decays in this weird logarithmic way???
	float yt = y_threshold;
	//yt *= 1. / 0.17;
	int pixel_threshold_y = int(trunc(pixels_y * yt)); 
	
	//if (pixel_pos_y >= pixel_threshold_y) { //2. / TEXTURE_PIXEL_SIZE.y > 500.) {
	if (pixel_threshold_y == 17) {
		col.r = 0.;
		COLOR.a = 1.;
	}
	
	//col = get_col(UV, TEXTURE_PIXEL_SIZE);
	
	COLOR.rgb = col;
	//COLOR = get_col(UV, TEXTURE_PIXEL_SIZE);
}