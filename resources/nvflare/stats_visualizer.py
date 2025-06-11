import argparse
import csv
import json

import matplotlib
import matplotlib.pyplot as plt
import numpy as np

matplotlib.rcParams["figure.figsize"] = (9.6, 7.2)


class StringListParser(argparse.Action):
    def __call__(self, parser, namespace, values, option_string=None):
        setattr(namespace, self.dest, values.split(","))


def build_parser():
    parser = argparse.ArgumentParser()
    parser.add_argument("-f", "--file")
    parser.add_argument(
        "-c", "--colors", default=["#3FB13D", "#FF8D1F", "#2D88C5"], action=StringListParser,
        help="Colors (in hex format, as a comma separated list) to use for Site1, Site2, and Total values in figure. Example: '#3FB13D,#FF8D1F,#2D88C5'",
    )
    parser.add_argument(
        "--names", default=["Site 1", "Site 2", "Global"], action=StringListParser,
        help="Labels (in order) to use for the legend as a comma-separated list. Example: 'test1,test2,test3'",
    )
    parser.add_argument(
        "-l", "--legend", action="store_true"
    )
    parser.add_argument(
        "-t", "--title", default="Average duration (in days) of conditions"
    )
    parser.add_argument(
        "-n", "--number", type=int, default=5,
        help="Number of conditions to display in figure"
    )

    return parser


def get_labels():
    with open("/app/condition_labels.csv") as f:
        reader = csv.DictReader(f)
        labels = {row["Concept Id"]: row["Name"] for row in reader }

    return labels


def main():
    parser = build_parser()
    args = parser.parse_args()
    with open(args.file) as f:
        stats = json.load(f)

    keys = list(list(stats.values())[0]["count"].keys())
    try:
        assert len(keys) > 1 and "Global" in keys, "Global and site-specific keys should be in data"
    except AssertionError as e:
        print(f"ERROR: There should be at least two sets of data, one of them from the central node: {str(e)}")
        exit(1)

    key_tot = "Global"
    keys.remove(key_tot)

    key1 = keys[0]
    key2 = keys[1] if len(keys) >= 2 else None

    counts = {}
    for k, v in stats.items():

        if (
                int(v["count"].get(key_tot, {}).get("data", 0)) <= 10 or
                any([key not in v["count"] for key in keys[:2]])
        ):
            continue
        counts.update({
            k: {
                f"site-{i+1}": int(v["count"].get(key, {}).get("data", 0))
                for i, key in enumerate(keys[:2])
            }
        })

        counts[k][key_tot] = int(v["count"].get(key_tot, {}).get("data", 0))

    highest_counts = sorted(list(counts.keys()), key=lambda k: counts[k][key_tot], reverse=True)[:args.number]
    # print(f"10 most common conditions: {highest_counts}")
    highest_counts = highest_counts[::-1]

    fig = plt.figure()
    ax = fig.add_subplot(111)

    avg_1 = [stats[x]["mean"][key1]["data"] for x in highest_counts]

    avg_tot = [stats[x]["mean"][key_tot]["data"] for x in highest_counts]
    print("Averages: ", end="")
    print(avg_1)

    ci_1 = [stats[x]["stddev"][key1]["data"]/np.sqrt(counts[x]["site-1"])*1.96 for x in highest_counts]
    print("Std Dev: ", end="")
    print(ci_1)

    if key2 is not None:
        avg_2 = [stats[x]["mean"][key2]["data"] for x in highest_counts]
        ci_2 = [stats[x]["stddev"][key2]["data"]/np.sqrt(counts[x]["site-2"])*1.96 for x in highest_counts]

    if any([isinstance(stats[x]["stddev"]["Global"]["data"], str) for x in highest_counts]):
        ci_tot = None
    else:
        ci_tot = [stats[x]["stddev"]["Global"]["data"]/np.sqrt(counts[x][key_tot])*1.96 for x in highest_counts]


    x_padding = 1.4
    idx = np.linspace(0, len(highest_counts)*x_padding, num=args.number)
    width = 0.3 if key2 is not None else 0.5

    if key2 is not None:
        ax1 = ax.barh(idx + width, avg_1, width, color=args.colors[0])
        ax.errorbar(y=[rect.get_y() + rect.get_height()/2 for rect in ax1], x=[rect.get_width() for rect in ax1], xerr=ci_1, color="black", fmt="none")

        ax2 = ax.barh(idx, avg_2, width, color=args.colors[1])
        ax.errorbar(y=[rect.get_y() + rect.get_height()/2 for rect in ax2], x=[rect.get_width() for rect in ax2], xerr=ci_2, color="black", fmt="none")

        ax3 = ax.barh(idx - width, avg_tot, width, color=args.colors[2])
        if ci_tot is not None:
            ax.errorbar(y=[rect.get_y() + rect.get_height()/2 for rect in ax3], x=[rect.get_width() for rect in ax3], xerr=ci_tot, color="black", fmt="none")

        count_labels = [
            [counts[x]["site-1"] for x in highest_counts],
            [counts[x]["site-2"] for x in highest_counts],
            [counts[x][key_tot] for x in highest_counts]
        ]
        if args.legend:
            ax.legend((ax1[0], ax2[0], ax3[0]), (args.names[0], args.names[1], args.names[2]))

    else:
        ax1 = ax.barh(idx + width/2.0, avg_1, width, color=args.colors[0])
        ax.errorbar(y=[rect.get_y() + rect.get_height()/2 for rect in ax1], x=[rect.get_width() for rect in ax1], xerr=ci_1, color="black", fmt="none")

        ax3 = ax.barh(idx - width/2.0, avg_tot, width, color=args.colors[2])
        if ci_tot is not None:
            ax.errorbar(y=[rect.get_y() + rect.get_height()/2 for rect in ax3], x=[rect.get_width() for rect in ax3], xerr=ci_tot, color="black", fmt="none")
        count_labels = [
            [counts[x]["site-1"] for x in highest_counts],
            None,
            [counts[x][key_tot] for x in highest_counts]
        ]
        if args.legend:
            ax.legend((ax1[0], ax3[0]), (args.names[0], args.names[2]))

    ytick_labels = get_labels()

    ax.set_title(args.title)
    ax.set_xlabel("Average condition duration (days)")
    ax.set_ylabel("Condition id")
    ax.set_yticks(idx)
    ax.set_yticklabels([ytick_labels[x] for x in highest_counts], wrap=True)
    # ax.set_yticklabels([ytick_labels[x] for x in highest_counts])

    def autolabel(rects, labels):
        for i, rect in enumerate(rects):
            text = f"N={labels[i]}"
            # h = rect.get_width()
            ax.text(0.1, rect.get_y(), text, ha="left", va="bottom")


    autolabel(ax1, count_labels[0])
    if key2 is not None:
        autolabel(ax2, count_labels[1])
    autolabel(ax3, count_labels[2])

    plt.savefig("stats.pdf", dpi=100)
    # plt.show()


if __name__ == "__main__":
    main()
