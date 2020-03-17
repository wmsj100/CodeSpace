#! /usr/bin/env python
# -*- coding: utf-8 -*-
# vim:fenc=utf-8
#
# Copyright © 2020 ubuntu <ubuntu@VM-0-13-ubuntu>
#
# Distributed under terms of the MIT license.

"""

"""

from flaskr import create_app

if __name__ == '__main__':
    app = create_app()
    app.run(debug=True, host='0.0.0.0', port=5200)
