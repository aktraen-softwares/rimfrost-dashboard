document.addEventListener("DOMContentLoaded", function () {
    var flashes = document.querySelectorAll(".flash");
    for (var i = 0; i < flashes.length; i++) {
        (function (flash) {
            setTimeout(function () {
                flash.style.opacity = "0";
                flash.style.transform = "translateY(-0.5rem)";
                flash.style.transition = "all 0.3s";
                setTimeout(function () {
                    flash.remove();
                }, 300);
            }, 4000);
        })(flashes[i]);
    }
});
