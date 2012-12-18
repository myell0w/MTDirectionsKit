function updateSaleBadgePosition() {
	// get position of logo
	var logo = $("#logo_container img");
	var badge = $("#sale_badge");
	var offset = logo.offset().left + logo.outerWidth() - badge.outerWidth() - 10;

	// update position of sale badge
	badge.offset({ top: 58, left: offset});
}

function showBadge() {
	var badge = $("#sale_badge");
	
	badge.slideDown();
}

$(document).ready(function() {
	updateSaleBadgePosition();
	showBadge();
});

$(window).resize(function() { 
	updateSaleBadgePosition();
});