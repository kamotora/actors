package ru.actors.ui;

import lombok.Getter;

import static ru.actors.ui.Main.ADDRESS;

@Getter
public enum Node {
    CUSTOMER("customer"),
    WAREHOUSE("warehouse"),
    OPERATOR("warehouse"),
    PAYMENT_SYSTEM("paymentSystem"),
    SELLER("seller");

    private final String id;

    Node(String id) {
        this.id = id + '@' + ADDRESS;
    }

    @Override
    public String toString() {
        return id;
    }
}
