'use strict';

global.$ = $;
global.jQuery = $;

import Rails from 'rails-ujs';
Rails.start();

import Turbolinks from 'turbolinks';
Turbolinks.start();

import 'bootstrap'
import 'src/application.scss'