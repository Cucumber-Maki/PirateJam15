@abstract
class_name Easings

# Based on https://easings.net/

enum Type {
	LINEAR,
	SINE_IN, SINE_OUT, SINE_IN_OUT,
	EXPONENTIAL_IN, EXPONENTIAL_OUT, EXPONENTIAL_IN_OUT,
	CIRCLE_IN, CIRCLE_OUT, CIRCLE_IN_OUT,
	BACK_IN, BACK_OUT, BACK_IN_OUT,
	ELASTIC_IN, ELASTIC_OUT, ELASTIC_IN_OUT,
	BOUNCE_IN, BOUNCE_OUT, BOUNCE_IN_OUT,
}

static func get_ease(p_type : Type, p_t : float) -> float:
	match (p_type):
		Type.SINE_IN: return ease_in_sine(p_t);
		Type.SINE_OUT: return ease_out_sine(p_t);
		Type.SINE_IN_OUT: return ease_in_out_sine(p_t);
		Type.EXPONENTIAL_IN: return ease_in_exponential(p_t);
		Type.EXPONENTIAL_OUT: return ease_out_exponential(p_t);
		Type.EXPONENTIAL_IN_OUT: return ease_in_out_exponential(p_t);
		Type.CIRCLE_IN: return ease_in_circle(p_t);
		Type.CIRCLE_OUT: return ease_out_circle(p_t);
		Type.CIRCLE_IN_OUT: return ease_in_out_circle(p_t);
		Type.BACK_IN: return ease_in_back(p_t);
		Type.BACK_OUT: return ease_out_back(p_t);
		Type.BACK_IN_OUT: return ease_in_out_back(p_t);
		Type.ELASTIC_IN: return ease_in_elastic(p_t);
		Type.ELASTIC_OUT: return ease_out_elastic(p_t);
		Type.ELASTIC_IN_OUT: return ease_in_out_elastic(p_t);
		Type.BOUNCE_IN: return ease_in_bounce(p_t);
		Type.BOUNCE_OUT: return ease_out_bounce(p_t);
		Type.BOUNCE_IN_OUT: return ease_in_out_bounce(p_t);
	return p_t;
static func get_ease_factor(p_type : Type, p_t : float, p_factor : float) -> float:
	match (p_type):
		Type.SINE_IN: return ease_in_sine(p_t);
		Type.SINE_OUT: return ease_out_sine(p_t);
		Type.SINE_IN_OUT: return ease_in_out_sine(p_t);
		Type.EXPONENTIAL_IN: return ease_in_exponential(p_t, p_factor);
		Type.EXPONENTIAL_OUT: return ease_out_exponential(p_t, p_factor);
		Type.EXPONENTIAL_IN_OUT: return ease_in_out_exponential(p_t, p_factor);
		Type.CIRCLE_IN: return ease_in_circle(p_t);
		Type.CIRCLE_OUT: return ease_out_circle(p_t);
		Type.CIRCLE_IN_OUT: return ease_in_out_circle(p_t);
		Type.BACK_IN: return ease_in_back(p_t, p_factor);
		Type.BACK_OUT: return ease_out_back(p_t, p_factor);
		Type.BACK_IN_OUT: return ease_in_out_back(p_t, p_factor);
		Type.ELASTIC_IN: return ease_in_elastic(p_t, p_factor);
		Type.ELASTIC_OUT: return ease_out_elastic(p_t, p_factor);
		Type.ELASTIC_IN_OUT: return ease_in_out_elastic(p_t, p_factor);
		Type.BOUNCE_IN: return ease_in_bounce(p_t);
		Type.BOUNCE_OUT: return ease_out_bounce(p_t);
		Type.BOUNCE_IN_OUT: return ease_in_out_bounce(p_t);
	return p_t;

#region Trigonometric

static func ease_in_sine(p_x : float) -> float:
	return 1.0 - cos(p_x * PI * 0.5);
static func ease_out_sine(p_x : float) -> float:
	return sin(p_x * PI * 0.5);
static func ease_in_out_sine(p_x : float) -> float:
	return -(cos(p_x * PI) - 1.0) * 0.5;

#endregion
#region Exponential

static func ease_in_exponential(p_x : float, p_exp : float = 2.0) -> float:
	return pow(p_x, p_exp);
static func ease_out_exponential(p_x : float, p_exp : float = 2.0) -> float:
	return 1.0 - ease_in_exponential(1.0 - p_x, p_exp);
static func ease_in_out_exponential(p_x : float, p_exp : float = 2.0) -> float:
	if (p_x < 0.5):
		return ease_in_exponential(2.0, p_exp - 1.0) * ease_in_exponential(p_x, p_exp);
	return 1.0 - ease_in_exponential((-2.0 * p_x) + 2.0, p_exp) * 0.5;

#endregion
#region Circular

static func ease_in_circle(p_x : float) -> float:
	return 1.0 - sqrt(1.0 - pow(p_x, 2.0));
static func ease_out_circle(p_x : float) -> float:
	return sqrt(1.0 - pow(p_x - 1.0, 2.0));
static func ease_in_out_circle(p_x : float) -> float:
	if (p_x < 0.5):
		return ease_in_circle(2.0 * p_x) * 0.5;
	return (ease_out_circle((-2.0 * p_x) + 3.0) + 1.0) * 0.5;

#endregion
#region Back

static func ease_in_back(p_x : float, p_factor : float = 1.70158) -> float:
	return ((p_factor - 1.0) * pow(p_x, 3.0)) - (p_factor * pow(p_x, 2.0));
static func ease_out_back(p_x : float, p_factor : float = 1.70158) -> float:
	return 1.0 + ((p_factor - 1.0) * pow(p_x - 1.0, 3.0)) + (p_factor * pow(p_x - 1.0, 2.0));
static func ease_in_out_back(p_x : float, p_factor : float = 1.70158) -> float:
	var factor2 := p_factor * 1.525;
	if (p_x < 0.5):
		return (pow(2.0 * p_x, 2.0) * (((factor2 + 1.0) * 2.0 * p_x) - factor2)) * 0.5;
	return (pow((2.0 * p_x) - 2.0, 2.0) * (((factor2 + 1.0) * ((p_x * 2.0) - 2.0)) + factor2) + 2.0) * 0.5;

#endregion
#region Elastic

static func ease_in_elastic(p_x : float, p_factor : float = 10.0) -> float:
	const c4 = (2.0 * PI) / 3.0;
	return -pow(2.0, (10.0 * p_x) - 10.0) * sin(((p_x * p_factor) - (p_factor + 0.75)) * c4);
static func ease_out_elastic(p_x : float, p_factor : float = 10.0) -> float:
	const c4 = (2.0 * PI) / 3.0;
	return pow(2.0, -10.0 * p_x) * sin(((p_x * p_factor) - 0.75) * c4) + 1.0;
static func ease_in_out_elastic(p_x : float, p_factor : float = 10.0) -> float:
	const c5 = (2.0 * PI) / 4.5;
	if (p_x < 0.5):
		return -pow(2.0, (20.0 * p_x) - 10.0) * sin(((p_x * p_factor) - (p_factor + 1.125)) * c5) * 0.5;
	return (pow(2.0, (-20.0 * p_x) + 10.0) * sin(((p_x * p_factor) - (p_factor + 1.125)) * c5) * 0.5) + 1.0;

#endregion
#region Bounce

static func ease_in_bounce(p_x : float) -> float:
	return 1.0 - ease_out_bounce(1.0 - p_x);
static func ease_out_bounce(p_x : float) -> float:
	const n1 = 7.5625;
	const d1 = 2.75;
	if (p_x < (1.0 / d1)):
		return n1 * pow(p_x, 2.0);
	elif (p_x < (2.0 / d1)):
		return (n1 * pow(p_x - (1.5 / d1), 2.0)) + 0.75;
	elif (p_x < (2.5 / d1)):
		return (n1 * pow(p_x - (2.25 / d1), 2.0)) + 0.9375;
	return (n1 * pow(p_x - (2.625 / d1), 2.0)) + 0.984375;
static func ease_in_out_bounce(p_x : float) -> float:
	if (p_x < 0.5):
		return (1.0 - ease_out_bounce(1.0 - (2.0 * p_x))) * 0.5;
	return (1.0 + ease_out_bounce((2.0 * p_x) - 1.0)) * 0.5;

#endregion
