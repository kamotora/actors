package ru.actors.ui;

import lombok.Getter;

import static ru.actors.ui.Main.ADDRESS;

@Getter
public enum MyNode {
    WAREHOUSE("warehouse"),
    OPERATOR("warehouse"),
    PAYMENT_SYSTEM("paymentSystem"),
    SELLER("seller"),
    CUSTOMER("customer"),;

    private final String id;
    private final String node;

    MyNode(String id) {
        this.id = id;
        this.node = id + '@' + ADDRESS;
    }
}
