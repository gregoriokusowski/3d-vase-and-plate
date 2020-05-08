# frozen_string_literal: true

require 'rubyscad'

SolidVase = Struct.new(:step_size, :height, :twist, :base_radius, :edges, :edgeness, :pinch, keyword_init: true) do
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

  def self.vase(params=BASE_PARAMS)
    difference do
      SolidVase.new(params.slice(*VASE_KEYS)).build
      difference do
        SolidVase.new(params.slice(*VASE_KEYS).merge(base_radius: params[:base_radius] - params[:wall_and_base_thickness])).build
        translate z: params[:step_size] do
          cylinder(r: params[:base_radius] * 2, h: params[:wall_and_base_thickness], center: true)
        end
      end
    end
  end

  def self.plate
    intersection do
      params = BASE_PARAMS
      cylinder(r: params[:base_radius] * 2, h: 30, center: true)
      vase(params.merge(radius: params[:base_radius] + (2 * params[:wall_and_base_thickness])))
    end
  end
end

VASE_KEYS = %i(step_size height twist base_radius edges edgeness pinch)
BASE_PARAMS = {
  step_size: 10,
  height: 100,
  twist: 90,
  base_radius: 50,
  edges: 12,
  edgeness: 5,
  pinch: 0.3,
  wall_and_base_thickness: 1.2
}

case ARGV.first
when 'vase'
  Group.vase
when 'plate'
  Group.plate
end
