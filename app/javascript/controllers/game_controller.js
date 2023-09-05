import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "rating", "maxPlayers", "maxPlayersGroup", "maxTeamsGroup" ]

  handleRatingChange(e) {
    if(this.ratingTarget.value === 'elo') {
      this.maxPlayersTarget.value = 1
      this.maxPlayersGroupTarget.style.display = 'none';
      this.maxTeamsGroupTarget.style.display = 'none';
    } else {
      this.maxPlayersTarget.value = 2
      this.maxPlayersGroupTarget.style.display = 'block';
      this.maxTeamsGroupTarget.style.display = 'block';
    }
  }

  get rating() {
    return this.ratingTarget.value
  }
}
