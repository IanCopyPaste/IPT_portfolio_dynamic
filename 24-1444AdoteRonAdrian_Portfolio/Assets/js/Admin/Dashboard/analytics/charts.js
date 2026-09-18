(function () {
    "use strict";

    var dash = window.AdminDash;
    var SVG_NS = "http://www.w3.org/2000/svg";

    // Column chart geometry. Bars are capped at 24px and rounded only at the data end, so they read as
    // growing from one baseline; the band left over either side of a bar is air.
    var HEIGHT = 240;
    var MARGIN = { top: 22, right: 8, bottom: 28, left: 34 };
    var MAX_BAR = 24;
    var BAR_SHARE = 0.6;
    var RADIUS = 4;
    // Below these band widths the month labels thin to every other one and the value labels move
    // to the tooltip and table, rather than colliding.
    var MIN_LABEL_BAND = 36;
    var MIN_VALUE_BAND = 22;

    var charts = dash.charts = {};

    var svg = function (tag, attrs) {
        var node = document.createElementNS(SVG_NS, tag);
        Object.keys(attrs || {}).forEach(function (key) {
            node.setAttribute(key, attrs[key]);
        });
        return node;
    };

    var empty = function (container, message) {
        dash.clear(container);
        container.appendChild(dash.el("p", { className: "adm-chart-empty", text: message }));
    };

    // Every value a chart draws is also in a table a screen reader can walk, so none of it is only
    // available as a picture.
    var srTable = function (caption, headers, rows) {
        return dash.el("table", { className: "adm-sr-only" }, [
            dash.el("caption", { text: caption }),
            dash.el("thead", null, [dash.el("tr", null, headers.map(function (header) {
                return dash.el("th", { scope: "col", text: header });
            }))]),
            dash.el("tbody", null, rows.map(function (row) {
                return dash.el("tr", null, row.map(function (cell) {
                    return dash.el("td", { text: String(cell) });
                }));
            }))
        ]);
    };

    // Round tick steps (1, 2, 5, 10, 20, ...) giving at most about four gridlines above zero. Counts
    // are whole numbers, so the step never drops below 1.
    var niceScale = function (max) {
        var raw = Math.max(max, 1) / 4;
        var magnitude = Math.pow(10, Math.floor(Math.log10(raw)));
        var normalised = raw / magnitude;
        var step = (normalised <= 1 ? 1 : normalised <= 2 ? 2 : normalised <= 5 ? 5 : 10) * magnitude;
        step = Math.max(1, Math.round(step));
        return { step: step, top: Math.max(step, Math.ceil(max / step) * step) };
    };

    // Square at the baseline, rounded at the top. A bar shorter than the radius just gets a smaller one.
    var barPath = function (x, y, width, height) {
        var r = Math.min(RADIUS, height, width / 2);
        return "M" + x + "," + (y + height) +
            "V" + (y + r) +
            "Q" + x + "," + y + " " + (x + r) + "," + y +
            "H" + (x + width - r) +
            "Q" + (x + width) + "," + y + " " + (x + width) + "," + (y + r) +
            "V" + (y + height) + "Z";
    };

    // "2026-09" -> a UTC date, so the month never shifts with the viewer's time zone.
    var monthDate = function (key) {
        var parts = key.split("-");
        return new Date(Date.UTC(+parts[0], +parts[1] - 1, 1));
    };

    var shortMonth = new Intl.DateTimeFormat(undefined, { month: "short", timeZone: "UTC" });

    // "Oct ’25" rather than the locale's "Oct 25", which reads as the 25th of October.
    var monthWithYear = function (date) {
        return shortMonth.format(date) + " ’" + String(date.getUTCFullYear()).slice(-2);
    };
    var longMonth = new Intl.DateTimeFormat(undefined, { month: "long", year: "numeric", timeZone: "UTC" });

    var tooltipFor = function (container) {
        var tip = container.querySelector(".adm-tooltip");
        if (!tip) {
            tip = dash.el("div", { className: "adm-tooltip", role: "presentation" });
            tip.hidden = true;
            container.appendChild(tip);
        }
        return tip;
    };

    var drawColumns = function (container, buckets, options) {
        var width = container.clientWidth;

        if (!width) {
            return;
        }

        var max = buckets.reduce(function (most, bucket) {
            return Math.max(most, bucket.count);
        }, 0);

        dash.clear(container);

        if (max === 0) {
            empty(container, options.emptyText);
            return;
        }

        var scale = niceScale(max);
        var plotWidth = width - MARGIN.left - MARGIN.right;
        var plotHeight = HEIGHT - MARGIN.top - MARGIN.bottom;
        var band = plotWidth / buckets.length;
        var barWidth = Math.min(MAX_BAR, Math.round(band * BAR_SHARE));
        var labelEvery = band < MIN_LABEL_BAND ? 2 : 1;
        var baseline = MARGIN.top + plotHeight;
        var yFor = function (value) {
            return MARGIN.top + plotHeight - (value / scale.top) * plotHeight;
        };

        var chart = svg("svg", {
            "class": "adm-columns",
            width: width,
            height: HEIGHT,
            viewBox: "0 0 " + width + " " + HEIGHT,
            "aria-hidden": "true",
            focusable: "false"
        });

        for (var tick = 0; tick <= scale.top; tick += scale.step) {
            var y = Math.round(yFor(tick)) + 0.5;
            chart.appendChild(svg("line", {
                "class": tick === 0 ? "adm-baseline" : "adm-grid-line",
                x1: MARGIN.left, x2: width - MARGIN.right, y1: y, y2: y
            }));
            var tickLabel = svg("text", { x: MARGIN.left - 8, y: y + 4, "text-anchor": "end" });
            tickLabel.textContent = dash.format.number(tick);
            chart.appendChild(tickLabel);
        }

        var tip = tooltipFor(container);
        var groups = [];

        buckets.forEach(function (bucket, index) {
            var bandX = MARGIN.left + index * band;
            var center = bandX + band / 2;
            var top = yFor(bucket.count);
            var group = svg("g", { "class": "adm-column-group" });

            // Drawn first and full height: the hover target for the whole month, empty or not.
            group.appendChild(svg("rect", {
                "class": "adm-column-band", x: bandX, y: MARGIN.top, width: band, height: plotHeight, rx: 4
            }));

            if (bucket.count > 0) {
                group.appendChild(svg("path", {
                    "class": "adm-column-bar",
                    d: barPath(center - barWidth / 2, top, barWidth, baseline - top)
                }));

                if (band >= MIN_VALUE_BAND) {
                    var value = svg("text", { "class": "adm-column-value", x: center, y: top - 6, "text-anchor": "middle" });
                    value.textContent = dash.format.number(bucket.count);
                    group.appendChild(value);
                }
            }

            // The newest month is always labelled; the thinning counts back from it.
            if ((buckets.length - 1 - index) % labelEvery === 0) {
                var date = monthDate(bucket.key);
                var showYear = index === 0 || date.getUTCMonth() === 0;
                var monthLabel = svg("text", { x: center, y: HEIGHT - 8, "text-anchor": "middle" });
                monthLabel.textContent = showYear ? monthWithYear(date) : shortMonth.format(date);
                group.appendChild(monthLabel);
            }

            group.addEventListener("pointerenter", function () {
                groups.forEach(function (other) {
                    other.classList.remove("is-hovered");
                });
                group.classList.add("is-hovered");

                dash.clear(tip);
                tip.appendChild(dash.el("strong", { text: dash.format.plural(bucket.count, options.unit) }));
                tip.appendChild(dash.el("span", { text: longMonth.format(monthDate(bucket.key)) }));
                tip.style.top = (bucket.count > 0 ? top : baseline) + "px";
                tip.hidden = false;
                // Centred on the column, but held inside the card at the first and last months.
                var half = tip.offsetWidth / 2;
                tip.style.left = Math.min(Math.max(center, half), width - half) + "px";
            });

            groups.push(group);
            chart.appendChild(group);
        });

        chart.addEventListener("pointerleave", function () {
            groups.forEach(function (group) {
                group.classList.remove("is-hovered");
            });
            tip.hidden = true;
        });

        container.appendChild(chart);
        container.appendChild(tip);
        container.appendChild(srTable(options.caption, ["Month", options.unitHeading], buckets.map(function (bucket) {
            return [longMonth.format(monthDate(bucket.key)), bucket.count];
        })));
    };

    // Redrawn to the card's new width whenever it changes (window resize, sidebar collapse), from the
    // data kept on the container.
    var resizeObserver = new ResizeObserver(function (entries) {
        entries.forEach(function (entry) {
            var container = entry.target;
            var width = Math.round(entry.contentRect.width);

            if (container._chart && width !== container._chart.width) {
                container._chart.width = width;
                drawColumns(container, container._chart.buckets, container._chart.options);
            }
        });
    });

    // options: { unit: "sign-up", unitHeading: "Sign-ups", caption, emptyText }
    charts.columns = function (container, buckets, options) {
        container._chart = { buckets: buckets, options: options, width: container.clientWidth };
        drawColumns(container, buckets, options);
        resizeObserver.observe(container);
    };

    // One bar split into parts of a whole, with a legend giving each part's count and share.
    // segments: [{ label, count, className }]
    charts.split = function (container, segments, options) {
        var total = segments.reduce(function (sum, segment) {
            return sum + segment.count;
        }, 0);

        if (total === 0) {
            empty(container, options.emptyText);
            return;
        }

        dash.clear(container);

        var bar = dash.el("div", { className: "adm-split", "aria-hidden": "true" });
        segments.forEach(function (segment) {
            if (segment.count > 0) {
                var part = dash.el("div", { className: "adm-split-segment " + segment.className });
                part.style.flexGrow = segment.count;
                bar.appendChild(part);
            }
        });

        var legend = dash.el("ul", { className: "adm-legend" }, segments.map(function (segment) {
            return dash.el("li", { className: "adm-legend-item" }, [
                dash.el("span", { className: "adm-legend-swatch " + segment.className, "aria-hidden": "true" }),
                dash.el("span", { className: "adm-legend-label", text: segment.label }),
                dash.el("span", { className: "adm-legend-value", text: dash.format.number(segment.count) }),
                dash.el("span", { className: "adm-legend-share", text: dash.format.percent(segment.count, total) + "%" })
            ]);
        }));

        container.appendChild(bar);
        container.appendChild(legend);
    };

    // Labelled horizontal bars, each drawn as its share of `total` and labelled with count and share.
    // rows: [{ label, count }]
    charts.barList = function (container, rows, total, options) {
        if (total === 0) {
            empty(container, options.emptyText);
            return;
        }

        dash.clear(container);

        container.appendChild(dash.el("ul", { className: "adm-barlist" }, rows.map(function (row) {
            var share = dash.format.percent(row.count, total);
            var fill = dash.el("div", { className: "adm-barlist-fill" });
            fill.style.width = (row.count / total) * 100 + "%";

            return dash.el("li", null, [
                dash.el("div", { className: "adm-barlist-head" }, [
                    dash.el("span", { className: "adm-barlist-label", text: row.label }),
                    dash.el("span", { className: "adm-barlist-value" }, [
                        dash.format.number(row.count),
                        dash.el("span", { text: " · " + share + "%" })
                    ])
                ]),
                dash.el("div", { className: "adm-barlist-track", "aria-hidden": "true" }, [fill])
            ]);
        })));
    };
})();
