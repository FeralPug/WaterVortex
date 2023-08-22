void Twirl(float2 uv, float2 center, float strength, float2 offset, out float2 Out) {
	float2 delta = uv - center;
	float angle = strength * length(delta);
	float x = cos(angle) * delta.x - sin(angle) * delta.y;
	float y = sin(angle) * delta.x + cos(angle) * delta.y;
	Out = float2(x + center.x + offset.x, y + center.y + offset.y);
}

void PolarCoord(float2 uv, float2 center, float radialScale, float lengthScale, out float2 Out) {
	float2 delta = uv - center;
	//float radius = length(delta) * 2 * radialScale;
	float radius = length(delta) * radialScale;
	float angle = atan2(delta.x, delta.y) * 1.0 / 6.28 * lengthScale;
	float fracAngle = frac(angle);
	angle = fwidth(angle) < fwidth(fracAngle) - 0.001 ? angle : fracAngle;
	Out = float2(radius, angle);
}

void PolarCoordVert(float2 uv, float2 center, float radialScale, float lengthScale, out float2 Out) {
	float2 delta = uv - center;
	//float radius = length(delta) * 2 * radialScale;
	float radius = length(delta) * radialScale;
	float angle = atan2(delta.x, delta.y) * 1.0 / 6.28 * lengthScale;
	Out = float2(radius, angle);
}


void Unity_Posterize_float4(float4 In, float4 Steps, out float4 Out)
{
    Out = floor(In / (1 / Steps)) * (1 / Steps);
}

float InverseLerp(float value, float2 minMax) {
    float t = (value - minMax.x) / (minMax.y - minMax.x);
    return saturate(t);
}

//noise

inline float unity_noise_randomValue(float2 uv)
{
    return frac(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453);
}

inline float unity_noise_interpolate(float a, float b, float t)
{
    return (1.0 - t) * a + (t * b);
}

inline float unity_valueNoise(float2 uv)
{
    float2 i = floor(uv);
    float2 f = frac(uv);
    f = f * f * (3.0 - 2.0 * f);

    uv = abs(frac(uv) - 0.5);
    float2 c0 = i + float2(0.0, 0.0);
    float2 c1 = i + float2(1.0, 0.0);
    float2 c2 = i + float2(0.0, 1.0);
    float2 c3 = i + float2(1.0, 1.0);
    float r0 = unity_noise_randomValue(c0);
    float r1 = unity_noise_randomValue(c1);
    float r2 = unity_noise_randomValue(c2);
    float r3 = unity_noise_randomValue(c3);

    float bottomOfGrid = unity_noise_interpolate(r0, r1, f.x);
    float topOfGrid = unity_noise_interpolate(r2, r3, f.x);
    float t = unity_noise_interpolate(bottomOfGrid, topOfGrid, f.y);
    return t;
}

void Unity_SimpleNoise_float(float2 UV, float Scale, out float Out)
{
    float t = 0.0;

    float freq = pow(2.0, float(0));
    float amp = pow(0.5, float(3 - 0));
    t += unity_valueNoise(float2(UV.x * Scale / freq, UV.y * Scale / freq)) * amp;

    freq = pow(2.0, float(1));
    amp = pow(0.5, float(3 - 1));
    t += unity_valueNoise(float2(UV.x * Scale / freq, UV.y * Scale / freq)) * amp;

    freq = pow(2.0, float(2));
    amp = pow(0.5, float(3 - 2));
    t += unity_valueNoise(float2(UV.x * Scale / freq, UV.y * Scale / freq)) * amp;

    Out = t;
}

