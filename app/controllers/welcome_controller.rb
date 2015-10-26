class WelcomeController < ApplicationController
  def index
  end

  def recognize
  	resp = NeuralNetwork.recognize(params[:image])

  	render text: resp
  end
end
