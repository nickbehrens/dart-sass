// Copyright 2016 Google Inc. Use of this source code is governed by an
// MIT-style license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'dart:collection';

import '../../visitor/interface/css.dart';
import '../../visitor/serialize.dart';
import '../node.dart';

abstract class CssNode extends AstNode {
  CssParentNode get parent => _parent;
  CssParentNode _parent;

  int _indexInParent;

  bool get isInvisible => false;

  /*=T*/ accept/*<T>*/(CssVisitor/*<T>*/ visitor);

  void remove() {
    if (_parent == null) {
      throw new StateError("Can't remove a node without a parent.");
    }

    _parent._children.removeAt(_indexInParent);
    for (var i = _indexInParent; i < _parent._children.length; i++) {
      _parent._children[i]._indexInParent--;
    }
  }

  String toString() => toCss(this);
}

// New at-rule implementations should add themselves to at-root's exclude logic.
abstract class CssParentNode extends CssNode {
  final List<CssNode> children;
  final List<CssNode> _children;

  bool get isInvisible {
    if (_isInvisible == null) {
      _isInvisible = children.every((child) => child.isInvisible);
    }
    return _isInvisible;
  }

  bool _isInvisible;

  CssParentNode() : this._([]);

  CssParentNode._(List<CssNode> children)
      : _children = children,
        children = new UnmodifiableListView<CssNode>(children);

  CssParentNode copyWithoutChildren();

  void addChild(CssNode child) {
    child._parent = this;
    child._indexInParent = _children.length;
    _children.add(child);
  }
}
