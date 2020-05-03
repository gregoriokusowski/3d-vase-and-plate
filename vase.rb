# frozen_string_literal: true

require 'rubyscad'

Vase = Struct.new(:step_size, :height, :twist, :base_radius, :edges, :edgeness, :pinch, keyword_init: true) do
  include RubyScad
  include Math

  def build
    steps = height/step_size
    twist_per_step = (twist.to_f/steps)
    union do
      (1..steps).each do |step|
        current_height = step_size * step
        trz translate: current_height, rotate: (-twist_per_step * step) do
          radius_factor = calculate_radius_factor(current_height)
          scale = calculate_radius_factor(current_height+step_size) / radius_factor
          linear_extrude height: step_size, scale: scale, twist: twist_per_step do
            star(radius_factor)
          end
        end
      end
    end
  end

  private

  def calculate_radius_factor(current_height)
    (pinch * sin((current_height.to_f / height * 360).radians)) + 1
  end

  def slice
    @slice ||= (360.to_f/(edges*2)).radians
  end

  # translate and rotate on z
  def trz(translate:, rotate:)
    self.translate z: translate do
      self.rotate z: rotate do
        yield
      end
    end
  end

  def star(radius_factor)
    ri = (base_radius - edgeness) * radius_factor
    re = base_radius * radius_factor
    polygon points: ((0...(edges*2)).map do |p|
      r = p.even? ? ri : re
      [r*cos((slice*p)), r*sin((slice*p))]
    end.to_a)
  end
end

class Group
  extend RubyScad
  def self.build(step_size: 10,
                 height: 100,
                 twist: 90,
                 base_radius: 50,
                 edges: 12,
                 edgeness: 5,
                 pinch: 0.3)
    # uncomment and increase the base radius for a plate
    #intersection do
      #cylinder(r: base_radius * 2, h: 30, center: true)
      difference do
        Vase.new(step_size: step_size,
                 height: height,
                 twist: twist,
                 base_radius: base_radius,
                 edges: edges,
                 edgeness: edgeness,
                 pinch: pinch).build
        difference do
          wall_and_base_thickness = 1.2 # step_size / 3
          Vase.new(step_size: step_size,
                   height: height,
                   twist: twist,
                   base_radius: base_radius - wall_and_base_thickness,
                   edges: edges,
                   edgeness: edgeness,
                   pinch: pinch).build
          translate z: step_size do
            cylinder(r: base_radius * 2, h: wall_and_base_thickness, center: true)
          end
        end
      end
    #end
  end
end

Group.build

