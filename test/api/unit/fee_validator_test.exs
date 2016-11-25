defmodule API.Repo.Changeset.Validators.FeeTest do
  use ExUnit.Case, async: true
  alias API.Repo.Changeset.Validators.Fee

  @fees [
    {1, 5.01}, {1.5, 5.01}, {2, 5.01}, {2.5, 5.01}, {3, 5.02}, {3.5, 5.02}, {4, 5.02}, {4.5, 5.02}, {5, 5.03},
    {5.5, 5.03}, {6, 5.03}, {6.5, 5.03}, {7, 5.04}, {7.5, 5.04}, {8, 5.04}, {8.5, 5.04}, {9, 5.05}, {9.5, 5.05},
    {10, 5.05}, {10.5, 5.05}, {11, 5.06}, {11.5, 5.06}, {12, 5.06}, {12.5, 5.06}, {13, 5.07}, {13.5, 5.07}, {14, 5.07},
    {14.5, 5.07}, {15, 5.08}, {15.5, 5.08}, {16, 5.08}, {16.5, 5.08}, {17, 5.09}, {17.5, 5.09}, {18, 5.09},
    {18.5, 5.09}, {19, 5.1}, {19.5, 5.1}, {20, 5.1}, {20.5, 5.1}, {21, 5.11}, {21.5, 5.11}, {22, 5.11},
    {22.5, 5.11}, {23, 5.12}, {23.5, 5.12}, {24, 5.12}, {24.5, 5.12}, {25, 5.13}, {25.5, 5.13}, {26, 5.13},
    {26.5, 5.13}, {27, 5.14}, {27.5, 5.14}, {28, 5.14}, {28.5, 5.14}, {29, 5.15}, {29.5, 5.15}, {30, 5.15},
    {30.5, 5.15}, {31, 5.16}, {31.5, 5.16}, {32, 5.16}, {32.5, 5.16}, {33, 5.17}, {33.5, 5.17}, {34, 5.17},
    {34.5, 5.17}, {35, 5.18}, {35.5, 5.18}, {36, 5.18}, {36.5, 5.18}, {37, 5.19}, {37.5, 5.19}, {38, 5.19},
    {38.5, 5.19}, {39, 5.2}, {39.5, 5.2}, {40, 5.2}, {40.5, 5.2}, {41, 5.21}, {41.5, 5.21}, {42, 5.21},
    {42.5, 5.21}, {43, 5.22}, {43.5, 5.22}, {44, 5.22}, {44.5, 5.22}, {45, 5.23}, {45.5, 5.23}, {46, 5.23},
    {46.5, 5.23}, {47, 5.24}, {47.5, 5.24}, {48, 5.24}, {48.5, 5.24}, {49, 5.25}, {49.5, 5.25}, {50, 5.25},
    {50.5, 5.25}, {51, 5.26}, {51.5, 5.26}, {52, 5.26}, {52.5, 5.26}, {53, 5.27}, {53.5, 5.27}, {54, 5.27},
    {54.5, 5.27}, {55, 5.28}, {55.5, 5.28}, {56, 5.28}, {56.5, 5.28}, {57, 5.29}, {57.5, 5.29}, {58, 5.29},
    {58.5, 5.29}, {59, 5.3}, {59.5, 5.3}, {60, 5.3}, {60.5, 5.3}, {61, 5.31}, {61.5, 5.31}, {62, 5.31},
    {62.5, 5.31}, {63, 5.32}, {63.5, 5.32}, {64, 5.32}, {64.5, 5.32}, {65, 5.33}, {65.5, 5.33}, {66, 5.33},
    {66.5, 5.33}, {67, 5.34}, {67.5, 5.34}, {68, 5.34}, {68.5, 5.34}, {69, 5.35}, {69.5, 5.35}, {70, 5.35},
    {70.5, 5.35}, {71, 5.36}, {71.5, 5.36}, {72, 5.36}, {72.5, 5.36}, {73, 5.37}, {73.5, 5.37}, {74, 5.37},
    {74.5, 5.37}, {75, 5.38}, {75.5, 5.38}, {76, 5.38}, {76.5, 5.38}, {77, 5.39}, {77.5, 5.39}, {78, 5.39},
    {78.5, 5.39}, {79, 5.4}, {79.5, 5.4}, {80, 5.4}, {80.5, 5.4}, {81, 5.41}, {81.5, 5.41}, {82, 5.41},
    {82.5, 5.41}, {83, 5.42}, {83.5, 5.42}, {84, 5.42}, {84.5, 5.42}, {85, 5.43}, {85.5, 5.43}, {86, 5.43},
    {86.5, 5.43}, {87, 5.44}, {87.5, 5.44}, {88, 5.44}, {88.5, 5.44}, {89, 5.45}, {89.5, 5.45}, {90, 5.45},
    {90.5, 5.45}, {91, 5.46}, {91.5, 5.46}, {92, 5.46}, {92.5, 5.46}, {93, 5.47}, {93.5, 5.47}, {94, 5.47},
    {94.5, 5.47}, {95, 5.48}, {95.5, 5.48}, {96, 5.48}, {96.5, 5.48}, {97, 5.49}, {97.5, 5.49}, {98, 5.49},
    {98.5, 5.49}, {99, 5.5}, {99.5, 5.5},
  ]

  @fees_1 [
    {1, 5.01}, {1.5, 5.02}, {2, 5.02}, {2.5, 5.03}, {3, 5.03}, {3.5, 5.04}, {4, 5.04}, {4.5, 5.05}, {5, 5.05},
    {5.5, 5.06}, {6, 5.06}, {6.5, 5.07}, {7, 5.07}, {7.5, 5.08}, {8, 5.08}, {8.5, 5.09}, {9, 5.09}, {9.5, 5.1},
    {10, 5.1}, {10.5, 5.11}, {11, 5.11}, {11.5, 5.12}, {12, 5.12}, {12.5, 5.13}, {13, 5.13}, {13.5, 5.14},
    {14, 5.14}, {14.5, 5.15}, {15, 5.15}, {15.5, 5.16}, {16, 5.16}, {16.5, 5.17}, {17, 5.17}, {17.5, 5.18},
    {18, 5.18}, {18.5, 5.19}, {19, 5.19}, {19.5, 5.2}, {20, 5.2}, {20.5, 5.21}, {21, 5.21}, {21.5, 5.22},
    {22, 5.22}, {22.5, 5.23}, {23, 5.23}, {23.5, 5.24}, {24, 5.24}, {24.5, 5.25}, {25, 5.25}, {25.5, 5.26},
    {26, 5.26}, {26.5, 5.27}, {27, 5.27}, {27.5, 5.28}, {28, 5.28}, {28.5, 5.29}, {29, 5.29}, {29.5, 5.3},
    {30, 5.3}, {30.5, 5.31}, {31, 5.31}, {31.5, 5.32}, {32, 5.32}, {32.5, 5.33}, {33, 5.33}, {33.5, 5.34}, {34, 5.34},
    {34.5, 5.35}, {35, 5.35}, {35.5, 5.36}, {36, 5.36}, {36.5, 5.37}, {37, 5.37}, {37.5, 5.38}, {38, 5.38},
    {38.5, 5.39}, {39, 5.39}, {39.5, 5.4}, {40, 5.4}, {40.5, 5.41}, {41, 5.41}, {41.5, 5.42}, {42, 5.42},
    {42.5, 5.43}, {43, 5.43}, {43.5, 5.44}, {44, 5.44}, {44.5, 5.45}, {45, 5.45}, {45.5, 5.46}, {46, 5.46},
    {46.5, 5.47}, {47, 5.47}, {47.5, 5.48}, {48, 5.48}, {48.5, 5.49}, {49, 5.49}, {49.5, 5.5}, {50, 5.5},
    {50.5, 5.51}, {51, 5.51}, {51.5, 5.52}, {52, 5.52}, {52.5, 5.53}, {53, 5.53}, {53.5, 5.54}, {54, 5.54},
    {54.5, 5.55}, {55, 5.55}, {55.5, 5.56}, {56, 5.56}, {56.5, 5.57}, {57, 5.57}, {57.5, 5.58}, {58, 5.58},
    {58.5, 5.59}, {59, 5.59}, {59.5, 5.6}, {60, 5.6}, {60.5, 5.61}, {61, 5.61}, {61.5, 5.62}, {62, 5.62},
    {62.5, 5.63}, {63, 5.63}, {63.5, 5.64}, {64, 5.64}, {64.5, 5.65}, {65, 5.65}, {65.5, 5.66}, {66, 5.66},
    {66.5, 5.67}, {67, 5.67}, {67.5, 5.68}, {68, 5.68}, {68.5, 5.69}, {69, 5.69}, {69.5, 5.7}, {70, 5.7},
    {70.5, 5.71}, {71, 5.71}, {71.5, 5.72}, {72, 5.72}, {72.5, 5.73}, {73, 5.73}, {73.5, 5.74}, {74, 5.74},
    {74.5, 5.75}, {75, 5.75}, {75.5, 5.76}, {76, 5.76}, {76.5, 5.77}, {77, 5.77}, {77.5, 5.78}, {78, 5.78},
    {78.5, 5.79}, {79, 5.79}, {79.5, 5.8}, {80, 5.8}, {80.5, 5.81}, {81, 5.81}, {81.5, 5.82}, {82, 5.82},
    {82.5, 5.83}, {83, 5.83}, {83.5, 5.84}, {84, 5.84}, {84.5, 5.85}, {85, 5.85}, {85.5, 5.86}, {86, 5.86},
    {86.5, 5.87}, {87, 5.87}, {87.5, 5.88}, {88, 5.88}, {88.5, 5.89}, {89, 5.89}, {89.5, 5.9}, {90, 5.9},
    {90.5, 5.91}, {91, 5.91}, {91.5, 5.92}, {92, 5.92}, {92.5, 5.93}, {93, 5.93}, {93.5, 5.94}, {94, 5.94},
    {94.5, 5.95}, {95, 5.95}, {95.5, 5.96}, {96, 5.96}, {96.5, 5.97}, {97, 5.97}, {97.5, 5.98}, {98, 5.98},
    {98.5, 5.99}, {99, 5.99}, {99.5, 6}
  ]

  describe "calculates fee" do
    test "by fix and percent" do
      for {amount, fee} <- @fees do
        assert Decimal.equal?(Decimal.new(fee), Fee.calculate(Decimal.new(amount), 0.5, 5, 0, :infinity))
      end

      for {amount, fee} <- @fees_1 do
        assert Decimal.equal?(Decimal.new(fee), Fee.calculate(Decimal.new(amount), 1, 5, 0, :infinity))
      end
    end

    test "with max" do
      assert Decimal.equal?(Decimal.new(50.5), Fee.calculate(Decimal.new(10000), 0.5, 5, 0, 50.5))
    end

    test "with min" do
      assert Decimal.equal?(Decimal.new(50.5), Fee.calculate(Decimal.new(1), 0.5, 5, 50.5, :infinity))
    end
  end
end