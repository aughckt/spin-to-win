shader_type canvas_item;

//uniform float progress: hint_range(0.0, 1.0, 0.01);
//uniform float strength: hint_range(0.0, 20.0, 0.1);

instance
uniform float y_threshold: hint_range(0.0, 1.0, 0.001) = 1.;

//uniform vec3 grey: source_color;

//uniform float border: hint_range(0.0, 1.0, 0.1);

int[2] get_size_pixels(vec2 texture_pixel_size) {
	vec2 pixels = trunc((1. / texture_pixel_size) / 3.);
	return int[] (int(pixels.x), int(pixels.y));
}

int get_pixel_y(float y, vec2 texture_pixel_size) {
	int pixels = get_size_pixels(texture_pixel_size)[1]; //int(trunc(1. / texture_pixel_size.y));
	int p = int(trunc(y * float(pixels)));
	return p;
}

/*vec4 get_col(vec2 uv, vec2 pixel_size) {
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
}*/

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
	/*float pixels_y = 1. / TEXTURE_PIXEL_SIZE.y;
	int pixel_pos_y = int(trunc(pixels_y * UV.y));
	
	float y = float(pixel_pos_y);
	
	//really dumb: the image is 17x17 and so of course 0.17 is equal 50% because why not
	//and also it decays in this weird logarithmic way???
	float yt = y_threshold;
	//yt *= 1. / 0.17;
	int pixel_threshold_y = int(trunc(pixels_y * yt)); */
	
	//if (pixel_pos_y >= pixel_threshold_y) { //2. / TEXTURE_PIXEL_SIZE.y > 500.) {
	//if (pixel_threshold_y == 17) {
	
	
	
	//if (get_pixel_y(UV.y, TEXTURE_PIXEL_SIZE) > 9) {
	//if (get_size_pixels(TEXTURE_PIXEL_SIZE)[1] == 18 * 3) {
	float yt = y_threshold;
	//doesnt look very good
	//yt += sin((UV.x / 1.3 + TIME) * 10.) * 0.06;
	vec2 uv = UV * 3.;
	//uv -= 1. / 
	uv = fract(uv);
	//uv.y -= trunc(uv.y);
	if (get_pixel_y(uv.y, TEXTURE_PIXEL_SIZE) >= get_pixel_y(yt, TEXTURE_PIXEL_SIZE)) {
		vec3 mono = vec3(col.g);
		col = mono;
		
		//col.r = 0.;
		//COLOR.a = 1.;
	}
	
	//col = get_col(UV, TEXTURE_PIXEL_SIZE);
	
	COLOR.rgb = col;
	//COLOR = get_col(UV, TEXTURE_PIXEL_SIZE);
}